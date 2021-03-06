;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   `(javascript
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press <SPC f e R> (Vim style) or
     ;; <M-m f e R> (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     auto-completion
     better-defaults
     emacs-lisp
     (latex :variables latex-enable-folding t
            latex-enable-auto-fill t)
     git
     version-control
     lsp
     ,(cond ((string= (system-name) "eicke-laptop")
            '(c-c++ :variables c-c++-backend 'lsp-ccls
                              ccls-executable "/home/eicke/git/ccls/Release/ccls" 
                              lsp-clients-clangd-executable "/home/eicke/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin/clangd"))
          ((string= (system-name) "nb108")
           '(c-c++ :variables c-c++-backend 'lsp-ccls
                              ccls-executable "/home/eichec/git/ccls/Release/ccls" 
                              lsp-clients-clangd-executable "/home/eichec/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin/clangd"))
          ((string= (system-name) "zeiss")
           '(c-c++ :variables c-c++-backend 'lsp-clangd
                  ccls-executable "/home/xyehecht/git/ccls/Release/ccls" 
                  lsp-clients-clangd-executable "/home/xyehecht/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin/clangd"))
          (t '(c-c++ :variables c-c++-backend 'lsp-clangd)))
     markdown
     cmake
     (python :variables python-backend 'lsp
             python-lsp-server 'pyls
             python-test-runner 'pytest)
     themes-megapack
     org
     pdf
     (shell :variables 
            shell-default-height 40
            shell-default-position 'bottom)
     spell-checking
     syntax-checking
     version-control
     dap
     (mu4e :variables
           mu4e-installation-path "/usr/share/emacs/site-lisp/mu4e/")
     )
   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(excorporate)
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https nil 
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 25
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `/emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim
   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("Source Code Pro"
                               :size 13
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers '(:relative t
                                :disabled-for-modes   dired-mode
                                                      doc-view-mode
                                :size-limit-kb 1000)
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   dotspacemacs-mode-line-theme 'spacemacs
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil
   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  (setq helm-make-executable "compiledb make")
  (setq lsp-file-watch-threshold nil)
  (setq lsp-log-io t)
  (setq  lsp-enabled-clients '(cimsel clangd))
  (setq tramp-remote-path '(tramp-default-remote-path  "~/.local/bin/" "~/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04/bin"))
  ;; mode line time stamp
  (setq display-time-24hr-format t)
  (setq display-time-format "%H:%M:%S")        ; add seconds
  (setq display-time-interval 1)               ; update every second
  (setq display-time-default-load-average nil) ; don't show load average
  (display-time-mode 1)                 ; show time in mode line on startup

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."

  ;; configure excorporate
  ;; allow opening the exchange calendar with 'e' from calendar 

  (evil-define-key 'motion calendar-mode-map "e" #'exco-calendar-show-day)
  (setq-default
   ;; configure email address and office 365 exchange server adddress for exchange web services
   excorporate-configuration
   (quote
    ("eicke.hecht@mixed-mode.de" . "https://owa.pixel-group.de/ews/exchange.asmx"))
   ;; integrate emacs diary entries into org agenda
   org-agenda-include-diary t
   )
  ;; activate excorporate and request user/password to start connection
  (excorporate)
  ;; enable the diary integration (i.e. write exchange calendar to emacs diary file -> ~/.emacs.d/diary must exist)
  (excorporate-diary-enable)
  (defun ab/agenda-update-diary ()
    "call excorporate to update the diary for today"
    (exco-diary-diary-advice (calendar-current-date) (calendar-current-date) #'message "diary updated")
    )
  (add-hook 'doc-view-mode-hook 'auto-revert-mode)
  ;; update the diary every time the org agenda is refreshed
  (add-hook 'org-agenda-cleanup-fancy-diary-hook 'ab/agenda-update-diary )
  (with-eval-after-load 'lsp-mode (lsp-register-client
  (make-lsp-client
    :new-connection (lsp-tramp-connection "clangd")
    :major-modes '(c-mode c++-mode)
    :remote? t
    :server-id 'clangd)))
  (setq mu4e-contexts
    `( ,(make-mu4e-context
    :name "Work"
    :enter-func (lambda () (mu4e-message "Switch to the Work context"))
    ;; leave-func not defined
    :match-func (lambda (msg)
      (when msg
        (mu4e-message-contact-field-matches msg
          :to "eicke.hecht@mixed-mode.de")))
    :vars '(  ( user-mail-address      .  "eicke.hecht@mixed-mode.de")
      ( user-full-name     . "Eicke Hecht" )
      ( mu4e-compose-signature .
        (concat
         "Mixed Mode GmbH"
         "Lochhamer Schlag 17     "
         "D-82166 Gräfelfing/München"
         "Tel.	+49 / 89 / 89 86 8-200"
         "Fax	+49 / 89 / 89 86 8-222 "
         "Mobil	+49 / 172 / "
         "http://www.mixed-mode.de"
         "Mixed Mode - Ihr Partner für Embedded & Software Engineering!"
         "-------"
"Ein Unternehmen der PIXEL Group"
         "Mixed Mode GmbH"
         "Sitz der Gesellschaft: Gräfelfing"
         "Amtsgericht: München"
         "HRB 130778"
         "Geschäftsführer: Helmut Süßmuth, Paul Privler"
         "------"
         "Diese E-Mail enthält vertrauliche und/oder rechtlich geschützte Informationen. "
         "Wenn Sie nicht der richtige Adressat sind oder diese E-Mail irrtümlich erhalten haben, informieren Sie bitte sofort den Absender und vernichten Sie diese Mail. "
         "Das unerlaubte Kopieren sowie die unbefugte Weitergabe dieser Mail sind nicht gestattet. "
         "Über das Internet versandte Emails können leicht unter fremden Namen erstellt oder manipuliert werden. "
         "Aus diesem Grunde bitten wir um Verständnis, dass wir zu Ihrem und unserem Schutz die rechtliche Verbindlichkeit der vorstehenden Erklärungen und Äußerungen ausschließen." ))))
      ))
  ;; set `mu4e-context-policy` and `mu4e-compose-policy` to tweak when mu4e should
  ;; guess or ask the correct context, e.g.

  ;; start with the first (default) context;
  ;; default is to ask-if-none (ask when there's no context yet, and none match)
  ;; (setq mu4e-context-policy 'pick-first)

  ;; compose with the current context is no context matches;
  ;; default is to ask
  ;; (setq mu4e-compose-context-policy nil)
  ;;; Set up some common mu4e variables
  (setq mu4e-maildir "~/mail/work"
        mu4e-trash-folder "/Trash"
        mu4e-refile-folder "/Archive"
        mu4e-sent-folder "/Sent"
        mu4e-drafts-folder "/Drafts"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval nil
        mu4e-compose-signature-auto-include nil
        mu4e-view-show-images t
        mu4e-view-show-addresses t)
  ;; SMTP settings
  (setq smtpmail-smtp-user "eichec"
        smtpmail-stream-type nil
        smtpmail-mail-address "eicke.hecht@mixed-mode.de"
        smtpmail-default-smtp-server "localhost"
        smtpmail-smtp-server "localhost"
        smtpmail-smtp-service 1025
        smtpmail-debug-info t)

;;; Mail directory shortcuts
;;  (setq mu4e-maildir-shortcuts
;;        '(("/gmail/INBOX" . ?g)
;;          ("/college/INBOX" . ?c)))

;;; Bookmarks
  (setq mu4e-bookmarks
        `(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
          ("date:today..now" "Today's messages" ?t)
          ("date:7d..now" "Last 7 days" ?w)
          ("mime:image/*" "Messages with images" ?p)
          (,(mapconcat 'identity
                       (mapcar
                        (lambda (maildir)
                          (concat "maildir:" (car maildir)))
                        mu4e-maildir-shortcuts) " OR ")
           "All inboxes" ?i)))
  )
  (with-eval-after-load 'org
    (setq org-todo-keywords
      '((sequence "TODO" "DOING" "BLOCKED" "REVIEW" "|" "DONE" "ARCHIVED"))))
  (with-eval-after-load 'org
    (setq org-todo-keyword-faces
      '(("TODO" . "Orange")
        ("DOING" . "DarkOrchid")
        ("BLOCKED" . "Firebrick")
        ("REVIEW" . "Teal")
        ("DONE" . "ForestGreen")
        ("ARCHIVED" .  "SlateBlue"))))
)
;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   (quote
    ("~/org/notes.org" "~/org/abschlussbericht_mbatt.org")))
 '(package-selected-packages
   (quote
    (mu4e-maildirs-extension mu4e-alert helm-mu fsm org-redmine yapfify yaml-mode utop tuareg caml seeing-is-believing rvm ruby-tools ruby-test-mode ruby-refactor ruby-hash-syntax rubocopfmt rubocop rspec-mode robe rbenv rake pytest pyenv-mode py-isort pippel pipenv pyvenv pip-requirements ocp-indent ob-elixir mvn minitest meghanada maven-test-mode lsp-python-ms lsp-java live-py-mode importmagic epc ctable concurrent helm-pydoc groovy-mode groovy-imports pcache gradle-mode flycheck-ocaml merlin flycheck-mix flycheck-credo emojify emoji-cheat-sheet-plus dune dap-mode bui tree-mode cython-mode company-emoji company-anaconda chruby bundler inf-ruby blacken auto-complete-rst anaconda-mode pythonic alchemist elixir-mode zenburn-theme zen-and-art-theme xterm-color ws-butler winum white-sand-theme which-key volatile-highlights vi-tilde-fringe uuidgen use-package unfill underwater-theme ujelly-theme twilight-theme twilight-bright-theme twilight-anti-bright-theme toxi-theme toc-org tao-theme tangotango-theme tango-plus-theme tango-2-theme sunny-day-theme sublime-themes subatomic256-theme subatomic-theme spaceline powerline spacegray-theme soothe-theme solarized-theme soft-stone-theme soft-morning-theme soft-charcoal-theme smyx-theme smeargle smartparens shell-pop seti-theme reverse-theme restart-emacs rebecca-theme rainbow-delimiters railscasts-theme purple-haze-theme professional-theme popwin planet-theme phoenix-dark-pink-theme phoenix-dark-mono-theme persp-mode pcre2el paradox orgit organic-green-theme org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-plus-contrib org-mime org-download org-bullets open-junk-file omtose-phellack-theme oldlace-theme occidental-theme obsidian-theme noctilux-theme neotree naquadah-theme mwim mustang-theme multi-term move-text monokai-theme monochrome-theme molokai-theme moe-theme minimal-theme material-theme markdown-toc markdown-mode majapahit-theme magit-gitflow magit-popup magit madhat2r-theme macrostep lush-theme lorem-ipsum linum-relative link-hint light-soap-theme jbeans-theme jazz-theme ir-black-theme inkpot-theme indent-guide hydra lv hungry-delete htmlize hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation heroku-theme hemisu-theme helm-themes helm-swoop helm-projectile projectile helm-mode-manager helm-make helm-gitignore request helm-flx helm-descbinds helm-company helm-c-yasnippet helm-ag hc-zenburn-theme gruvbox-theme gruber-darker-theme grandshell-theme gotham-theme google-translate golden-ratio gnuplot gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md gandalf-theme fuzzy flyspell-correct-helm flyspell-correct flycheck-pos-tip pos-tip flycheck pkg-info epl flx-ido flx flatui-theme flatland-theme fill-column-indicator farmhouse-theme fancy-battery eyebrowse expand-region exotica-theme exec-path-from-shell evil-unimpaired evil-search-highlight-persist highlight evil-numbers evil-nerd-commenter transient git-commit with-editor evil-escape goto-chg eval-sexp-fu espresso-theme eshell-z eshell-prompt-extras esh-help elisp-slime-nav dumb-jump f s dracula-theme django-theme disaster diminish diff-hl define-word darktooth-theme autothemer dash darkokai-theme darkmine-theme darkburn-theme dakrone-theme cyberpunk-theme company-statistics company-c-headers company-auctex company column-enforce-mode color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized cmake-mode clues-theme clean-aindent-mode clang-format cherry-blossom-theme busybee-theme bubbleberry-theme birds-of-paradise-plus-theme bind-map bind-key badwolf-theme auto-yasnippet yasnippet auto-highlight-symbol auto-dictionary auto-compile packed apropospriate-theme anti-zenburn-theme ample-zen-theme ample-theme alect-themes aggressive-indent afternoon-theme ace-window ace-link ace-jump-helm-line helm avy helm-core async ac-ispell auto-complete popup)))
 '(send-mail-function (quote smtpmail-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)

