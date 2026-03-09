# Resume

My resume, version-controlled and auto-generated as a PDF on every commit.

## Setup

**1. Clone the repo and install the hook:**
```bash
git clone <your-repo>
cd <your-repo>
bash scripts/setup_hook.sh
```

**2. Make sure Docker Desktop is installed and running.**

That's it! From now on, every time you commit a change to `resume.json`, a PDF is automatically generated and committed to `output/resume.pdf`.

---

## How it works

```
edit resume.json → git commit → post-commit hook fires
→ Docker spins up RxResume → imports JSON → exports PDF
→ PDF committed to output/resume.pdf → Docker tears down
```

If Docker isn't running when you commit, the hook skips gracefully and tells you how to generate the PDF manually.

---

## Branching strategy

Each branch can be a different tailored version of your resume:

| Branch | Purpose |
|---|---|
| `main` | Latest general resume |
| `frontend-focused` | Tailored for frontend roles |
| `senior-roles` | Tailored for senior positions |

Every branch has its own PDF history — just `git log output/resume.pdf` to see all versions.

---

## Manual PDF generation

If you need to regenerate the PDF without committing:

```bash
# Make sure Docker is running first
bash scripts/export_pdf.sh resume.json output/resume.pdf
```

---

## Files

```
resume/
├── resume.json                  # source of truth — edit this
├── output/
│   └── resume.pdf               # auto-generated, do not edit manually
├── hooks/
│   └── post-commit              # the git hook (source)
└── scripts/
    ├── setup_hook.sh            # installs the hook into .git/hooks
    └── export_pdf.sh            # generates the PDF via RxResume + Docker
```
