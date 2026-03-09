#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from http.cookiejar import CookieJar


def _request(method, url, data=None, headers=None, cookies=None, timeout=20):
    if data is not None and not isinstance(data, (bytes, bytearray)):
        data = data.encode("utf-8")
    req = urllib.request.Request(url, data=data, method=method)
    for key, value in (headers or {}).items():
        req.add_header(key, value)
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(cookies)
    )
    try:
        with opener.open(req, timeout=timeout) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as err:
        return err.code, err.read()


def _json_dumps(payload):
    return json.dumps(payload, separators=(",", ":"))


def _wait_for_health(base_url, timeout_s, interval_s):
    health_url = f"{base_url}/api/health"
    attempts = int(timeout_s / interval_s)
    for i in range(1, attempts + 1):
        status, _ = _request("GET", health_url, timeout=3)
        if status == 200:
            print("✅ RxResume is up!")
            return True
        print(f"Attempt {i}/{attempts} - not ready yet...")
        time.sleep(interval_s)
    return False


def main():
    parser = argparse.ArgumentParser(description="Generate resume PDF via RxResume")
    parser.add_argument("resume_json", nargs="?", default="resume.json")
    parser.add_argument("output_pdf", nargs="?", default="output/resume.pdf")
    args = parser.parse_args()

    base_url = os.environ.get("RXRESUME_BASE_URL", "http://localhost:3000").rstrip("/")
    email = os.environ.get("RXRESUME_EMAIL", "ci.user@example.com")
    password = os.environ.get("RXRESUME_PASSWORD", "CiPassword123!")
    username = os.environ.get("RXRESUME_USERNAME", "ci-user")
    display_username = os.environ.get("RXRESUME_DISPLAY_USERNAME", "ci-user")
    wait_timeout = int(os.environ.get("RXRESUME_WAIT_TIMEOUT", "60"))
    wait_interval = int(os.environ.get("RXRESUME_WAIT_INTERVAL", "3"))
    request_timeout = int(os.environ.get("RXRESUME_REQUEST_TIMEOUT", "20"))

    print("⏳ Waiting for RxResume to be ready...")
    if not _wait_for_health(base_url, wait_timeout, wait_interval):
        print("❌ RxResume did not become ready in time.")
        return 1

    cookies = CookieJar()

    print("📝 Registering CI user...")
    sign_up_payload = {
        "name": "CI User",
        "username": username,
        "displayUsername": display_username,
        "email": email,
        "password": password,
        "callbackURL": "/dashboard",
    }
    _request(
        "POST",
        f"{base_url}/api/auth/sign-up/email",
        data=_json_dumps(sign_up_payload),
        headers={"Content-Type": "application/json"},
        cookies=cookies,
        timeout=request_timeout,
    )

    print("🔐 Logging in...")
    sign_in_payload = {"email": email, "password": password}
    status, body = _request(
        "POST",
        f"{base_url}/api/auth/sign-in/email",
        data=_json_dumps(sign_in_payload),
        headers={"Content-Type": "application/json"},
        cookies=cookies,
        timeout=request_timeout,
    )
    if status != 200:
        print(f"❌ Login failed with status {status}")
        try:
            print(body.decode("utf-8"))
        except UnicodeDecodeError:
            print(body)
        return 1
    print("✅ Logged in!")

    print("📤 Importing resume JSON...")
    with open(args.resume_json, "r", encoding="utf-8") as handle:
        resume_data = json.load(handle)

    import_payload = {"json": {"data": resume_data}, "meta": []}
    status, body = _request(
        "POST",
        f"{base_url}/api/rpc/resume/import",
        data=_json_dumps(import_payload),
        headers={"Content-Type": "application/json"},
        cookies=cookies,
        timeout=request_timeout,
    )
    if status != 200:
        print(f"❌ Import failed with status {status}")
        print(body.decode("utf-8"))
        return 1

    resume_id = json.loads(body.decode("utf-8"))["json"]
    print(f"✅ Resume imported with ID: {resume_id}")

    print("🖨️ Exporting PDF...")
    print_payload = {"json": {"id": resume_id}, "meta": []}
    status, body = _request(
        "POST",
        f"{base_url}/api/rpc/printer/printResumeAsPDF",
        data=_json_dumps(print_payload),
        headers={"Content-Type": "application/json"},
        cookies=cookies,
        timeout=request_timeout,
    )
    if status != 200:
        print(f"❌ Print failed with status {status}")
        print(body.decode("utf-8"))
        return 1

    pdf_url = json.loads(body.decode("utf-8"))["json"]["url"]
    os.makedirs(os.path.dirname(args.output_pdf), exist_ok=True)
    status, pdf_body = _request(
        "GET",
        pdf_url,
        cookies=cookies,
        timeout=request_timeout,
    )
    if status != 200:
        print(f"❌ Download failed with status {status}")
        return 1

    with open(args.output_pdf, "wb") as handle:
        handle.write(pdf_body)

    print(f"✅ PDF saved to {args.output_pdf}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
