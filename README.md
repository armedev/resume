# Resume

My resume, version-controlled and generated as a PDF on tag releases.

Latest PDF (after tag release): `https://<OWNER>.github.io/<REPO>/resume.pdf`

Thanks to RxResume for the awesome resume builder: https://github.com/AmruthPillai/Reactive-Resume

## Setup

**1. Clone the repo.**
```bash
git clone <your-repo>
cd <your-repo>
```

**2. Make sure Docker Desktop is installed and running (for local generation).**

---

## Generate resume.json from RxResume

If you prefer using the RxResume UI, you can export your resume as JSON and drop it into this repo:

1. Open RxResume and finish editing your resume.
2. Use the Export → JSON option.
3. Save the file as `resume.json` in the repo root.

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

## Custom domain setup

Use a subdomain like `resume.arme.dev` for the PDF.

1. DNS (Netlify DNS)
   - Add a CNAME record:
     - Name: `resume`
     - Value: `<YOUR_GITHUB_USERNAME>.github.io`
2. GitHub repo → Settings → Pages
   - Source: GitHub Actions
   - Custom domain: `resume.arme.dev`
   - Enable HTTPS once available
3. Trigger a new tag release to publish to the domain

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

## Repo safeguards checklist

**Branch protection**
- Protect `main` and require PRs before merging
- Restrict who can push to `main`

**Tag protection**
- Protect tag pattern `v*`
- Allow only maintainers to push tags

**GitHub Pages environment**
- Allow deployments from tags (`v*`)
- Remove required reviewers unless you want manual approval

**Repository settings**
- Disable Actions from forks if you want to control releases
- Keep `output/resume.pdf` untracked to avoid history bloat

---

## Files

```
resume/
├── resume.json                  # source of truth — edit this
├── docker-compose.ci.yml         # local/CI RxResume stack
├── output/
│   └── .gitkeep                 # keep the output directory
├── .github/
│   └── workflows/
│       └── generate.yml          # tag-based PDF generation + Pages
└── scripts/
    ├── generate_pdf.py          # generates the PDF via RxResume + Docker
    ├── local_pdf.sh             # quick local test runner
    ├── update_image_digest.sh   # pin latest RxResume image digest
    └── export_pdf.sh            # wrapper for generate_pdf.py

```
