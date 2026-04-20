# CV-as-Code

Templated resume built with LaTeX, generated from YAML data via Jinja2, compiled and deployed automatically through GitHub Actions to GitHub Pages.

**Live:** [cv.cosmdandy.dev](https://cv.cosmdandy.dev)

## Structure

```
cv/
├── template/
│   ├── cv.tex.j2              Jinja2 template (bilingual)
│   └── developercv.cls        LaTeX document class
├── scripts/
│   └── build.py               YAML + Jinja2 → LaTeX generator
├── pages/
│   ├── fonts/                 Self-hosted Inter font
│   └── index.html             Landing page
├── .github/workflows/
│   ├── build-deploy.yml       Build PDF, convert to WebP, deploy to Pages
│   └── docker-image.yml       Build custom TeX Live Docker image
├── cv-data.example.yaml       Example CV data
├── cv-data.yaml               Your data (gitignored, injected via secret)
├── Dockerfile                 Custom TeX Live image for fast CI builds
└── Makefile                   Local build commands
```

## Use as Your Own CV

1. **Fork** this repository

2. **Fill in your data** — copy the example and edit:
   ```bash
   cp cv-data.example.yaml cv-data.yaml
   ```

3. **Add the `CV_DATA` secret** to your GitHub repo (Settings → Secrets → Actions):
   ```bash
   # macOS
   base64 < cv-data.yaml | pbcopy
   # Linux
   base64 -w 0 < cv-data.yaml
   ```
   Paste the output as the value of `CV_DATA`.

4. **Update `CNAME`** with your domain, or delete it to use `username.github.io/cv`

5. **Enable GitHub Pages:** Settings → Pages → Source: **GitHub Actions**

6. **Push** — the pipeline builds the PDF, converts it to WebP, and deploys

## Local Development

**Requirements:** Python 3.9+, LaTeX with XeTeX

```bash
pip install -r requirements.txt

# Generate .tex and compile to PDF
make build

# Build using example data (no real data needed)
make build-example

# Generate .tex only (no LaTeX required)
make render
```
