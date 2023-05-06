# Emacs Configuration for Multiple Language Development

This configuration includes support for Rust and Java development.

# Rust

Rust development with emacs is very pleasant indeed.

F12 is bound to `rustic-format-buffer`

```
(global-set-key [f12] 'rustic-format-buffer)
```

# Java Language Server

See https://github.com/emacs-lsp/lsp-java

## Updating the Eclipse JDT Language Server Version

Look for the following in the elpa/lsp-java-XXX/lsp-java.el file. Here's what I am using in May 2023 (this version supports JDK 20).

```
(defcustom lsp-java-jdt-download-url "https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.23.0/jdt-language-server-1.23.0-202304271346.tar.gz"
  "JDT JS download url.
```

Change the download URL to the desired version.  Remove the `lsp-java.elc` file in order to force emacs to recompile the file.

Note that the Language Server will be installed in the location specified by `lsp-java-server-install-dir`. Example:

```
(setq lsp-java-server-install-dir "/Users/ahmed/Downloads/jdtls/")
```

## Java Code Formatting

See https://github.com/redhat-developer/vscode-java/wiki/Formatter-settings

Import project into Eclipse and go to 

Properties > Java Code Style > Formatter 

and create a new formatting.  The formatting rules will be written to `.settings/org.eclipse.jdt.core.prefs`.

Alternatively, download a code formatting XML file such as the Google formatter and that can be used by adding to the `lsp-java` config:

(use-package lsp-java
  :ensure t
  :init
  :config (
    add-hook 'java-mode-hook 'lsp
    (setq lsp-java-format-settings-url (lsp--path-to-uri "/work/emacs-configuration/eclipse-java-google-style.xml"))
  )
)

F12 and F9 are bound to `lsp-format-buffer` and `lsp-organize-imports` respectively:

```
(global-set-key [f12] 'lsp-format-buffer)
(global-set-key [f9] 'lsp-organize-imports)
```
