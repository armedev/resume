# Resume

My resume, version-controlled and generated as a PDF on tag releases.

## Setup

**1. Clone the repo.**
```bash
git clone <your-repo>
cd <your-repo>
```

**2. Make sure Docker Desktop is installed and running (for local generation).**

---

## How it works

```
edit resume.json → push tag → GitHub Actions runs
→ Docker spins up RxResume → imports JSON → exports PDF
→ PDF uploaded to the GitHub Release for that tag
```

---

## Branching strategy

Each branch can be a different tailored version of your resume:

| Branch | Purpose |
|---|---|
| `main` | Latest general resume |
| `frontend-focused` | Tailored for frontend roles |
| `senior-roles` | Tailored for senior positions |

Each tag has a PDF attached in GitHub Releases.

---

## Manual PDF generation

If you need to regenerate the PDF locally:

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
    └── export_pdf.sh            # wrapper for generate_pdf.py
```
