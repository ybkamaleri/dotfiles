;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Wouter Spekkink"
      user-mail-address "wahsp@tutanota.com")

;; Font settings
(setq doom-font (font-spec :family "RobotoMono Nerd Font"  :size 18)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font Mono" :size 15))

;; Theme
(setq doom-theme 'doom-dracula)

;; Set line-number style
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Exit insert mode by pressing j twice quickly
(setq key-chord-two-keys-delay 0.1)
(key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
(key-chord-mode 1)
(setq evil-escape-key-sequence nil)

;; doom-mode-line stuff
(setq doom-modeline-enable-word-count t)

;; helm-bibtex related stuff
(after! helm
  (use-package! helm-bibtex
    :custom
    (bibtex-completion-bibliography '("~/Tools/Zotero/bibtex/library.bib"))
    (reftex-default-bibliography '("~/Tools/Zotero/bibtex/library.bib"))
    (bibtex-completion-pdf-field "file")
    :hook (Tex . (lambda () (define-key Tex-mode-map "\C-ch" 'helm-bibtex))))
  (map! :leader
        :desc "Open literature database"
        "o l" #'helm-bibtex)
  (map! :map helm-map
        "C-j" #'helm-next-line
        "C-k" #'helm-previous-line)
)

;; org-mode related stuff
(after! org
  ;; Set org directories
  (setq org-directory "~/org/")
  (setq org-default-notes-file "~/org/refile.org")
  (setq org-agenda-files (quote("~/org/"
                                "~/org/synced/"
                                "~/org/org-roam/"
                                "~/org/org-roam/daily/"
                                "~/Documents/EUR/Writing/Q-SoPrA/")))
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-ellipsis " ▼ ")
  (setq org-hide-emphasis-markers t)
  (setq org-log-done 'time)

  ;; org keyword related stuff
  (setq org-todo-keywords
        (quote ((sequence
                 "TODO(t)"
                 "PROJ(p)"
                 "LOOP(r)"
                 "STRT(s)"
                 "IDEA(i)"
                 "NEXT(n)"
                 "|"
                 "DONE(d)")
                (sequence
                 "WAIT(w@/!)"
                 "HOLD(h@/!)"
                 "|"
                 "KILL(k@/!)")
                (sequence
                 "[ ](T)"
                 "[-](S)"
                 "[?](W)"
                 "|"
                 "[X](D)"
                 ))))

  (setq org-todo-keyword-faces
       (quote (
               ("NEXT" +-lock-constant-face bold))))

  (setq org-todo-state-tags-triggers
        (quote (("KILL" ("KILL" . t))
                ("WAIT" ("WAIT" . t))
                ("HOLD" ("WAIT") ("HOLD" . t))
                (done ("WAIT") ("HOLD"))
                ("TODO" ("WAIT") ("KILL") ("HOLD"))
                ("NEXT" ("WAIT") ("KILL") ("HOLD"))
                ("DONE" ("WAIT") ("KILL") ("HOLD")))))

  ;; org capture related stuff
  (use-package! org-capture-pop-frame)
  (setq org-capture-templates
        (quote (("p" "project" entry (file+headline "~/org/refile.org" "Projects")
                 "* PROJ %?\n%U\n%a\n")
                ("t" "todo" entry (file+headline "~/org/refile.org" "Tasks")
                 "* TODO %?\nSCHEDULED: %t\n%U\n%a\n")
                ("i" "idea" entry (file+headline "~/org/refile.org" "Ideas")
                 "* IDEA %?\n%U\n%a\n")
                ("p" "Protocol" entry (file+headline "~/org/refile.org" "Emails")
                 "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
	        ("L" "Protocol Link" entry (file+headline "~/org/refile.org" "Emails")
                 "* %? [[%:link][%:description]] \nCaptured On: %U"))))

  ;; Kill capture frame
  (defvar kk/delete-frame-after-capture 0 "Whether to delete the last frame after the current capture")

  (defun kk/delete-frame-if-neccessary (&rest r)
    (cond
     ((= kk/delete-frame-after-capture 0) nil)
     ((> kk/delete-frame-after-capture 1)
      (setq kk/delete-frame-after-capture (- kk/delete-frame-after-capture 1)))
     (t
      (setq kk/delete-frame-after-capture 0)
      (delete-frame))))

  (advice-add 'org-capture-finalize :after 'kk/delete-frame-if-neccessary)
  (advice-add 'org-capture-kill :after 'kk/delete-frame-if-neccessary)
  (advice-add 'org-capture-refile :after 'kk/delete-frame-if-neccessary)

  ;; Stuff for capturing external things
 (defun make-capture-frame (&optional capture-url)  
   "Create a new frame and run org-capture."  
   (interactive)  
   (make-frame '((name . "capture") 
                 (width . 120) 
                 (height . 15)))  
   (select-frame-by-name "capture") 
   (setq word-wrap 1)
   (setq truncate-lines nil)
   (if capture-url (org-protocol-capture capture-url) (org-capture)))

  ;; org refile related stuff
  (setq org-refle-targets (quote ((nil :maxlevel . 9)
                                  (org-agenda-files :maxlevel . 9)
                                  ("~/org/org-roam/" :maxlevel . 9))))

  (setq org-refile-use-outline-path t)

  (setq org-refile-allow-creating-parent-nodes (quote confirm))

  (defun ws/verify-refile-target ()
    "Eclude todo keywords with a done state"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  ;; Prevent adding org agenda files
  (map! :map org-mode-map "C-c [" nil)

  ;; Set up org-ref stuff
  (use-package! org-ref
    :custom
    (org-ref-default-bibliography "/home/wouter/Tools/Zotero/bibtex/library.bib")
    (org-ref-default-citation-link "citep"))

  (defun my/org-ref-open-pdf-at-point ()
    "Open the pdf for bibtex key under point if it exists."
    (interactive)
    (let* ((results (org-ref-get-bibtex-key-and-file))
           (key (car results))
           (pdf-file (funcall org-ref-get-pdf-filename-function key)))
      (if (file-exists-p pdf-file)
          (find-file pdf-file)
        (message "No PDF found for %s" key))))

  (setq org-ref-completion-library 'org-ref-ivy-cite
        org-export-latex-format-toc-function 'org-export-latex-no-toc
        org-ref-get-pdf-filename-function
        (lambda (key) (car (bibtex-completion-find-pdf key)))
        org-ref-open-pdf-function 'my/org-ref-open-pdf-at-point
        ;; For pdf export engines
        org-latex-pdf-process (list "latexmk -pdflatex='%latex -shell-escape -interaction nonstopmode' -pdf -bibtex -f -output-directory=%o %f")
        org-ref-notes-function 'orb-edit-notes)

  ;; Set up org-mode export stuff
  (setq org-latex-to-mathml-convert-command
      "java -jar %j -unicode -force -df %o %I"
      org-latex-to-mathml-jar-file
      "/home/wouter/Tools/math2web/mathtoweb.jar")

  (add-to-list 'org-latex-classes
               '("apa6"
                 "\\documentclass{apa6}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

  (add-to-list 'org-latex-classes
               '("report"
                 "\\documentclass{report}"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

  (add-to-list 'org-latex-classes
               '("koma-article"
                 "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

  (add-to-list 'org-latex-classes
               '("memoir"
                 "\\documentclass{memoir}"
                 ("\\book{%s}" . "\\book*{%s}")
                 ("\\part{%s}" . "\\part*{%s}")
                 ("\\chapter{%s} .\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes
               '("paper"
                 "\\documentclass{paper}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

  (defun org-export-latex-no-toc (depth)
    (when depth
      (format "%% Org-mode is exporting headings to %s levels.\n"
              depth)))

  ;; org-noter stuff
  (after! org-noter
    (setq
     org-noter-notes-search-path '("~/org/org-roam/")
     org-noter-hide-other nil
     org-noter-separate-notes-from-heading t
     org-noter-always-create-frame nil)
    (map!
     :map org-noter-doc-mode-map
     :leader
     :desc "Insert note"
     "m i" #'org-noter-insert-note
     :desc "Insert precise note"
     "m p" #'org-noter-insert-precise-note
     :desc "Go to previous note"
     "m k" #'org-noter-sync-prev-note
     :desc "Go to next note"
     "m j" #'org-noter-sync-next-note
     :desc "Create skeleton"
     "m s" #'org-noter-create-skeleton
     :desc "Kill session"
     "m q" #'org-noter-kill-session
     )
    )
  )

;; This is to use pdf-tools instead of doc-viewer
(use-package! pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))

;; org-roam related things
(after! org-roam
  (setq org-roam-directory "~/org/org-roam")

  (add-hook 'after-init-hook 'org-roam-mode)

  ;; Let's set up some org-roam capture templates
  (setq org-roam-capture-templates
        (quote (("d" "default" plain (function org-roam--capture-get-point)
                 "%?"
                 :file-name "%<%Y-%m-%d-%H%M%S>-${slug}"
                 :head "#+title: ${title}\n"
                 :unnarrowed t)
                )))

  ;; And now we set necessary variables for org-roam-dailies
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           #'org-roam-capture--get-point
           "* %?"
           :file-name "daily/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n\n")))

  ;; For org-roam server
  (require 'org-roam-protocol)
  (use-package! org-roam-server
    :config
    (setq org-roam-server-host "127.0.0.1"
          org-roam-server-port 8080
          org-roam-server-authenticate nil
          org-roam-server-export-inline-images t
          org-roam-server-serve-files nil
          org-roam-server-served-file-extensions '("pdf" "mp4" "ogv")
          org-roam-server-network-poll t
          org-roam-server-network-arrows nil
          org-roam-server-network-label-truncate t
          org-roam-server-network-label-truncate-length 60
          org-roam-server-network-label-wrap-length 20))

  ;; Function to capture quotes from pdf
  (defun org-roam-capture-pdf-active-region ()
    (let* ((pdf-buf-name (plist-get org-capture-plist :original-buffer))
           (pdf-buf (get-buffer pdf-buf-name)))
      (if (buffer-live-p pdf-buf)
          (with-current-buffer pdf-buf
            (car (pdf-view-active-region-text)))
        (user-error "Buffer %S not alive." pdf-buf-name))))

  ;; org-roam-bibtex stuff
  (use-package! org-roam-bibtex
    :hook (org-roam-mode . org-roam-bibtex-mode))

  (setq orb-preformat-keywords
        '("citekey" "title" "url" "author-or-editor" "keywords" "file")
        orb-process-file-keyword t
        orb-file-field-extensions '("pdf"))

  (setq orb-templates
        '(("r" "ref" plain(function org-roam-capture--get-point)
           ""
           :file-name "${citekey}"
           :head "#+TITLE: ${citekey}: ${title}\n#+ROAM_KEY: ${ref}
- tags ::
- keywords :: ${keywords}

* Notes
:PROPERTIES:
:Custom_ID: ${citekey}
:URL: ${url}
:AUTHOR: ${author-or-editor}
:NOTER_DOCUMENT: ${file}
:NOTER_PAGE:
:END:")))
  )

;; For deft
(after! deft
  (setq deft-extensions '("org"))
  (setq deft-directory "~/org/org-roam/")
  (setq deft-recursive t))

;; For textklintrc
(after! flycheck
  (setq flycheck-textlint-config "~/.config/textlint/textlintrc.json")
  (setq flycheck-textlint-executable "~/npm-workspace/node_modules/.bin/textlint")
  )

;; For calendar support
(defun my-open-calendar()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "Green")
    )))

;; Spelling related
(global-set-key (kbd "C-c N")
                (lambda()(interactive)
                  (ispell-change-dictionary "dutch")
                  (flyspell-buffer)))

;; Adding some new global keys
(map! :leader
      :desc "Open calendar"
      "o c" #'my-open-calendar)

(map! :leader
      :desc "Org noter"
      "n p" #'org-noter)
