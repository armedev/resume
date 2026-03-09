# Resume

My resume, version-controlled and generated as a PDF on tag releases.

Latest PDF (after tag release): `https://<OWNER>.github.io/<REPO>/resume.pdf`

## Setup

**1. Clone the repo.**
```bash
git clone <your-repo>
cd <your-repo>
```

**2. Make sure Docker Desktop is installed and running (for local generation).**

---

## Release flow

Tag a release to generate a new PDF:
```bash
git tag vYYYY.MM.DD
git push origin vYYYY.MM.DD
```

Artifacts:
- GitHub Releases → `resume.pdf`
- GitHub Pages → `/resume.pdf`

---

## Fork and use your own resume

**1. Fork the repo and clone your fork.**

**2. Replace `resume.json` with your own data.**

**3. Enable GitHub Actions + Pages in your fork.**
- Repo → Settings → Actions → allow workflows
- Repo → Settings → Pages → Source: GitHub Actions

**4. Tag a release to generate your PDF.**

Your PDF will be available at:
- `https://<OWNER>.github.io/<REPO>/resume.pdf`
- GitHub Releases → latest tag asset

---

## How it works

```
edit resume.json → push tag → GitHub Actions runs
→ Docker spins up RxResume → imports JSON → exports PDF
→ PDF uploaded to the GitHub Release and GitHub Pages
```

---

## Manual PDF generation

Fast local testing before pushing changes:

```bash
./scripts/local_pdf.sh
```

This starts the Docker stack if needed, generates the PDF, and leaves the stack running for faster repeats.
Stop it when you're done:

```bash
docker compose -f docker-compose.ci.yml down
```

If you want to run against an already-running stack:

```bash
# Make sure Docker is running first
python3 scripts/generate_pdf.py resume.json output/resume.pdf
```

---

## Files

```
resume/
├── resume.json                  # source of truth — edit this
├── output/
│   └── .gitkeep                 # keep the output directory
└── scripts/
    ├── generate_pdf.py          # generates the PDF via RxResume + Docker
    ├── local_pdf.sh             # quick local test runner
    └── export_pdf.sh            # wrapper for generate_pdf.py
```
