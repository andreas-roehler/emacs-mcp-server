;;; mcp-server-emacs-tools.el --- Emacs-specific MCP Tools -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;;; Commentary:

;; This module loads and registers Emacs-specific MCP tools from the tools/ directory.
;; Users can customize which tools are enabled via `mcp-server-emacs-tools-enabled'.

;;; Code:

(require 'mcp-server-tools)

(defgroup mcp-server-emacs-tools nil
  "Emacs-specific MCP tools configuration."
  :group 'mcp-server
  :prefix "mcp-server-emacs-tools-")

(defcustom mcp-server-emacs-tools-enabled 'all
  "Which MCP tools to enable.
Can be `all' to enable all available tools, or a list of tool
names (symbols) to enable selectively.

Available tools:
- `eval-elisp' - Execute arbitrary Elisp expressions
- `get-diagnostics' - Get flycheck/flymake diagnostics

Example: \\='(get-diagnostics) to enable only diagnostics."
  :type '(choice (const :tag "All tools" all)
                 (repeat :tag "Selected tools" symbol))
  :group 'mcp-server-emacs-tools)

(defconst mcp-server-emacs-tools--available
  '((eval-elisp . (mcp-server-emacs-tools-eval-elisp
                   mcp-server-emacs-tools--eval-elisp-register))
    (get-diagnostics . (mcp-server-emacs-tools-diagnostics
                        mcp-server-emacs-tools--diagnostics-register)))
  "Alist mapping tool names to (feature register-function) pairs.")

;; Add tools directory to load path
(let* ((this-file (or load-file-name buffer-file-name))
       (tools-dir (and this-file
                       (expand-file-name "tools" (file-name-directory this-file)))))
  (when tools-dir
    (add-to-list 'load-path tools-dir)))

(defun mcp-server-emacs-tools--tool-enabled-p (tool-name)
  "Return non-nil if TOOL-NAME is enabled."
  (or (eq mcp-server-emacs-tools-enabled 'all)
      (memq tool-name mcp-server-emacs-tools-enabled)))

(defun mcp-server-emacs-tools-register ()
  "Register enabled Emacs MCP tools.
Only tools listed in `mcp-server-emacs-tools-enabled' are loaded.
This function can be called multiple times to re-register tools
after `mcp-server-tools-cleanup'."
  (dolist (tool-spec mcp-server-emacs-tools--available)
    (let* ((tool-name (car tool-spec))
           (feature (cadr tool-spec))
           (register-fn (caddr tool-spec)))
      (when (mcp-server-emacs-tools--tool-enabled-p tool-name)
        (require feature)
        (when (fboundp register-fn)
          (funcall register-fn))))))

;; Register tools on initial load
(mcp-server-emacs-tools-register)

(provide 'mcp-server-emacs-tools)

;;; mcp-server-emacs-tools.el ends here
