# CV-as-Code

[![Open in GitHub Codespaces][codespaces]](https://codespaces.new/CosmDandy/cv.cosmdandy.dev)

[![build][build]](https://github.com/CosmDandy/cv.cosmdandy.dev/actions/workflows/build-deploy.yml) [![SLSA][SLSA]](https://slsa.dev) [![license][license]](LICENSE)

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

## Credits

`template/developercv.cls` is the [Developer CV](https://www.latextemplates.com/template/developer-cv)
class by Jan Vorisek, Jan Küster and Vel (LaTeXTemplates.com), MIT.

## License

MIT — see [LICENSE](LICENSE). The licence covers the build tooling and templates;
your own `cv-data.yaml` is yours and never enters the repository.

[codespaces]: https://github.com/codespaces/badge.svg
[build]: https://img.shields.io/github/actions/workflow/status/CosmDandy/cv.cosmdandy.dev/build-deploy.yml?branch=master&style=flat&label=build&labelColor=21262d&logo=githubactions&logoColor=8b949e
[SLSA]: https://img.shields.io/badge/SLSA-3-7828dc?style=flat&labelColor=21262d&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAABGdBTUEAALGPC%2FxhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAABMlBMVEXvMQDvMADwMQDwMADwMADvMADvMADwMADwMQDvMQDvMQDwMADwMADvMADwMADwMADwMQDvMQDvMQDwMQDvMQDwMQDwMADwMADwMQDwMADwMADvMADvMQDvMQDwMADwMQDwMADvMQDwMADwMQDwMADwMADwMADwMADwMADwMADvMQDvMQDwMADwMQDwMADvMQDvMQDwMADvMQDvMQDwMADwMQDwMQDwMQDvMQDwMADvMADwMADwMQDvMQDwMADwMQDwMQDwMQDwMQDvMQDvMQDvMADwMADvMADvMADvMADwMQDwMQDvMADvMQDvMQDvMADvMADvMQDwMQDvMQDvMADvMADvMADvMQDwMQDvMQDvMQDvMADvMADwMADvMQDvMQDvMQDvMADwMADwMQDwMAAAAAA%2FHoSwAAAAY3RSTlMpsvneQlQrU%2FLQSWzvM5DzmzeF9Pi%2BN6vvrk9HuP3asTaPgkVFmO3rUrMjqvL6d0LLTVjI%2FPuMQNSGOWa%2F6YU8zNuDLihJ0e6aMGzl8s2IT7b6lIFkRj1mtvQ0eJW95rG0%2BSid59x%2FAAAAAWJLR0Rltd2InwAAAAlwSFlzAAAOwwAADsMBx2%2BoZAAAAAd0SU1FB%2BYHGg0tGLrTaD4AAACqSURBVAjXY2BgZEqGAGYWVjYGdg4oj5OLm4eRgZcvBcThFxAUEk4WYRAVE09OlpCUkpaRTU6WY0iWV1BUUlZRVQMqUddgSE7W1NLS1gFp0NXTB3KTDQyNjE2Sk03NzC1A3GR1SytrG1s7e4dkBogtjk7OLq5uyTCuu4enl3cyhOvj66fvHxAIEmYICg4JDQuPiAQrEmGIio6JjZOFOjSegSHBBMpOToxPAgCJfDZC%2Fm2KHgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyMi0wNy0yNlQxMzo0NToyNCswMDowMC8AywoAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjItMDctMjZUMTM6NDU6MjQrMDA6MDBeXXO2AAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm%2B48GgAAAABJRU5ErkJggg%3D%3D
[license]: https://img.shields.io/github/license/CosmDandy/cv.cosmdandy.dev?style=flat&label=license&labelColor=21262d&color=484f58&logo=opensourceinitiative&logoColor=8b949e
