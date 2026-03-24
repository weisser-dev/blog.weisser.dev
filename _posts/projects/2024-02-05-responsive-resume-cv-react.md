---
title: "A Fully Responsive Multilingual Resume/CV as a React App"
date: 2024-02-05
categories:
  - typescript
tags:
  - typescript
  - react
  - resume
  - multilingual
repo: https://github.com/weisser-dev/responsive-resume-cv-react
read_time: true
---

Maintaining a resume is one of those tasks that's easy to put off because updating a Word document or a PDF template is tedious and the result is never quite right. At some point I decided that if I was going to keep my resume current, the tooling needed to be pleasant to use. So I built a React application that renders a complete, responsive CV from a structured JSON configuration and deploys automatically to GitHub Pages.

The content model separates data from presentation. All resume content — personal info, work history, education, skills, certifications, languages — lives in a typed TypeScript object. The React components are purely presentational: they receive data and render it, with no hardcoded strings. This means updating the resume is a matter of editing the config file, pushing to main, and the GitHub Actions deployment handles the rest.

Multilingual support was a genuine requirement, not an afterthought. I work in both German and English contexts, and having two separate resume files to maintain was already painful. The app supports locale switching, where each text field in the config can provide values for multiple languages. Switching the displayed language is instant — no reload, no separate URL — because it's just a React state change that causes the locale-aware components to re-render with the appropriate strings.

The print stylesheet deserves a mention. The whole point of a web-based resume is that it renders well both on screen and when printed or exported to PDF. Getting the print layout right required some careful CSS: suppressing navigation elements, adjusting font sizes, controlling page breaks to avoid orphaned headings, and ensuring the color scheme works in black-and-white printing. It took longer than the rest of the styling work combined, but the end result prints cleanly on a single page without manual adjustments.
