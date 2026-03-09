# Resume

My resume, version-controlled and auto-generated as a PDF on every push.

## How it works

1. Edit `resume.json` (exported from [RxResume](https://rxresume.org))
2. Push to any branch
3. GitHub Actions spins up a self-hosted RxResume instance via Docker
4. Imports the JSON, exports a PDF
5. Commits `output/resume.pdf` back to the same branch

## Branching strategy

Each branch can be a different version of your resume:

| Branch | Purpose |
|---|---|
| `main` | Latest general resume |
| `frontend-focused` | Tailored for frontend roles |
| `senior-roles` | Tailored for senior positions |

## Local usage

To generate the PDF locally:

```bash
# Start the stack
docker compose -f docker-compose.ci.yml up -d

# Run the export script
bash scripts/export_pdf.sh resume.json output/resume.pdf

# Tear down
docker compose -f docker-compose.ci.yml down
```

## Updating your resume

1. Export your resume JSON from RxResume (`Settings → Export → JSON`)
2. Replace `resume.json` in this repo
3. Push — PDF is auto-generated and committed

Or edit `resume.json` directly and push.
