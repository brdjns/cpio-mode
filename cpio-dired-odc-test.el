;; -*- coding: utf-8 -*-
;;; cpio-dired-test.el --- Tests of cpio-dired-mode.
;	$Id: cpio-dired-odc-test.el,v 1.9 2018/11/29 01:57:15 doug Exp $	

;; COPYRIGHT

;; Copyright © 2017, 2018 Douglas Lewan, d.lewan2000@gmail.com.
;; All rights reserved.
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Douglas Lewan (d.lewan2000@gmail.com)
;; Maintainer: -- " --
;; Created: 2018 Mar 23
;; Version: 0.02
;; Keywords: cpio-mode, cpio-dired-mode, automated test

;;; Commentary:

;; This file defines and runs tests of commands in cpio-dired-mode.
;; The tests are admittedly to a certain degree rosy scenario tests.
;; In particular, there's no error case verification.
;; You are, of course, free to add such testing.

;; Most tests run a few variants.
;; For example, (1) operate on this entry,
;; (2) operate on the next N entries,
;; (3) operate on entries matching a regular expression.

;; Since there are three objects of interest:
;; (1) the archive itself,
;; (2) the catalog, and
;; (3) the dired-style buffer,
;; all three tend to be checked after an operation.

;;; Documentation:

;;; Code:

;;
;; Dependencies
;; 
(load (concat default-directory "test-generic.el"))

(eval-when-compile
  (if (file-exists-p (concat default-directory "cpio.elc"))
      (load (concat default-directory "cpio.elc")))
  (load (concat default-directory "cpio.el")))

;;;;;;;;;;;;;;;;
;; Things to make the byte compiler happy.
(defvar *cpio-odc-filename-re-idx*)
(defvar *cpio-odc-filesize-re-idx*)
(defvar *cpio-odc-gid-re-idx*)
(defvar *cpio-odc-gid-re-idx*)
(defvar *cpio-odc-header-re*)
(defvar *cpio-odc-magic-re-idx*)
(defvar *cpio-odc-mode-re-idx*)
(defvar *cpio-odc-namesize-re-idx*)
(defvar *cpio-odc-nlink-re-idx*)
(defvar *cpio-odc-uid-re-idx*)
(defvar cpio-archive-buffer)
(defvar cpio-catalog-contents-after)
(defvar cpio-catalog-contents-before)
(defvar cpio-contents-buffer)
(defvar cpio-contents-buffer-string)
(defvar cpio-dired-buffer)
(defvar cpio-dired-catalog-contents-before)
(defvar cpio-dired-del-marker)
(defvar cpio-dired-keep-marker-copy-str)
(defvar cpio-dired-keep-marker-rename)
(defvar run-dir)
(declare-function cpio-catalog "cpio.el")
(declare-function cpio-contents-buffer-name "cpio.el")
(declare-function cpio-dired-add-entry "cpio-dired.el")
(declare-function cpio-dired-buffer-name "cpio-dired.el")
(declare-function cpio-dired-change-marks "cpio-dired.el")
(declare-function cpio-dired-clean-directory "cpio-dired.el")
(declare-function cpio-dired-copy-entry-name-as-kill "cpio-dired.el")
(declare-function cpio-dired-create-directory "cpio-dired.el")
(declare-function cpio-dired-diff "cpio-dired.el")
(declare-function cpio-dired-display-entry "cpio-dired.el")
(declare-function cpio-dired-do-async-shell-command "cpio-dired.el")
(declare-function cpio-dired-do-chgrp "cpio-dired.el")
(declare-function cpio-dired-do-chmod "cpio-dired.el")
(declare-function cpio-dired-do-chown "cpio-dired.el")
(declare-function cpio-dired-do-compress "cpio-dired.el")
(declare-function cpio-dired-do-copy "cpio-dired.el")
(declare-function cpio-dired-do-copy-regexp "cpio-dired.el")
(declare-function cpio-dired-do-delete "cpio-dired.el")
(declare-function cpio-dired-do-flagged-delete "cpio-dired.el")
(declare-function cpio-dired-do-hardlink "cpio-dired.el")
(declare-function cpio-dired-do-hardlink-regexp "cpio-dired.el")
(declare-function cpio-dired-do-isearch "cpio-dired.el")
(declare-function cpio-dired-do-isearch-regexp "cpio-dired.el")
(declare-function cpio-dired-do-kill-lines "cpio-dired.el")
(declare-function cpio-dired-do-print "cpio-dired.el")
(declare-function cpio-dired-do-query-replace-regexp "cpio-dired.el")
(declare-function cpio-dired-do-redisplay "cpio-dired.el")
(declare-function cpio-dired-do-rename "cpio-dired.el")
(declare-function cpio-dired-do-rename-regexp "cpio-dired.el")
(declare-function cpio-dired-do-search "cpio-dired.el")
(declare-function cpio-dired-do-symlink "cpio-dired.el")
(declare-function cpio-dired-do-symlink-regexp "cpio-dired.el")
(declare-function cpio-dired-do-touch "cpio-dired.el")
(declare-function cpio-dired-downcase "cpio-dired.el")
(declare-function cpio-dired-extract-all "cpio-dired.el")
(declare-function cpio-dired-extract-entries "cpio-dired.el")
(declare-function cpio-dired-find-alternate-entry "cpio-dired.el")
(declare-function cpio-dired-find-entry-other-window "cpio-dired.el")
(declare-function cpio-dired-flag-auto-save-entries "cpio-dired.el")
(declare-function cpio-dired-flag-backup-entries "cpio-dired.el")
(declare-function cpio-dired-flag-entries-regexp "cpio-dired.el")
(declare-function cpio-dired-flag-entry-deletion "cpio-dired.el")
(declare-function cpio-dired-flag-garbage-entries "cpio-dired.el")
(declare-function cpio-dired-get-entry-name "cpio-dired.el")
(declare-function cpio-dired-goto-entry "cpio-dired.el")
(declare-function cpio-dired-hide-all "cpio-dired.el")
(declare-function cpio-dired-hide-details-mode "cpio-dired.el")
(declare-function cpio-dired-hide-subdir "cpio-dired.el")
(declare-function cpio-dired-isearch-entry-names "cpio-dired.el")
(declare-function cpio-dired-isearch-entry-names-regexp "cpio-dired.el")
(declare-function cpio-dired-kill "cpio-dired.el")
(declare-function cpio-dired-mark "cpio-dired.el")
(declare-function cpio-dired-mark-directories "cpio-dired.el")
(declare-function cpio-dired-mark-entries-containing-regexp "cpio-dired.el")
(declare-function cpio-dired-mark-entries-regexp "cpio-dired.el")
(declare-function cpio-dired-mark-executables "cpio-dired.el")
(declare-function cpio-dired-mark-subdir-entries "cpio-dired.el")
(declare-function cpio-dired-mark-symlinks "cpio-dired.el")
(declare-function cpio-dired-mark-this-entry "cpio-dired.el")
(declare-function cpio-dired-mouse-find-entry-other-window "cpio-dired.el")
(declare-function cpio-dired-move-to-first-entry "cpio-dired.el")
(declare-function cpio-dired-next-dirline "cpio-dired.el")
(declare-function cpio-dired-next-line "cpio-dired.el")
(declare-function cpio-dired-next-marked-entry "cpio-dired.el")
(declare-function cpio-dired-prev-marked-entry "cpio-dired.el")
(declare-function cpio-dired-previous-line "cpio-dired.el")
(declare-function cpio-dired-save-archive "cpio-dired.el")
(declare-function cpio-dired-show-entry-type "cpio-dired.el")
(declare-function cpio-dired-sort-toggle-or-edit "cpio-dired.el")
(declare-function cpio-dired-toggle-marks "cpio-dired.el")
(declare-function cpio-dired-toggle-read-only "cpio-dired.el")
(declare-function cpio-dired-undo "cpio-dired.el")
(declare-function cpio-dired-unmark "cpio-dired.el")
(declare-function cpio-dired-unmark-all-entries "cpio-dired.el")
(declare-function cpio-dired-unmark-all-marks "cpio-dired.el")
(declare-function cpio-dired-unmark-backward "cpio-dired.el")
(declare-function cpio-dired-up-directory "cpio-dired.el")
(declare-function cpio-dired-upcase "cpio-dired.el")
(declare-function cpio-dired-view-archive "cpio-dired.el")
(declare-function cpio-dired-view-entry "cpio-dired.el")
(declare-function cpio-epa-dired-do-decrypt "cpio-dired.el")
(declare-function cpio-epa-dired-do-encrypt "cpio-dired.el")
(declare-function cpio-epa-dired-do-sign "cpio-dired.el")
(declare-function cpio-epa-dired-do-verify "cpio-dired.el")
(declare-function cpio-image-dired-delete-tag "cpio-dired.el")
(declare-function cpio-image-dired-dired-comment-entries "cpio-dired.el")
(declare-function cpio-image-dired-dired-display-external "cpio-dired.el")
(declare-function cpio-image-dired-dired-display-image "cpio-dired.el")
(declare-function cpio-image-dired-dired-edit-comment-and-tags "cpio-dired.el")
(declare-function cpio-image-dired-dired-toggle-marked-thumbs "cpio-dired.el")
(declare-function cpio-image-dired-display-thumb "cpio-dired.el")
(declare-function cpio-image-dired-display-thumbs "cpio-dired.el")
(declare-function cpio-image-dired-display-thumbs-append "cpio-dired.el")
(declare-function cpio-image-dired-jump-thumbnail-buffer "cpio-dired.el")
(declare-function cpio-image-dired-mark-tagged-entries "cpio-dired.el")
(declare-function cpio-image-dired-tag-entries "cpio-dired.el")
(declare-function cpio-mode "cpio.el")
(declare-function cpio-view-dired-style-buffer "cpio.el")
;; EO for the byte compiler.
;;;;;;;;;;;;;;;;


;; 
;; Vars
;; 

(defvar *cdmt-odc-small-archive* "test_data/alphabet/alphabet_small.odc.cpio"
  "A small archive used for testing.")
(setq *cdmt-odc-small-archive* "test_data/alphabet/alphabet_small.odc.cpio")
(defvar *cdmt-odc-large-archive* "test_data/alphabet/alphabet.odc.cpio"
  "A large archive used for testing.")
(setq *cdmt-odc-large-archive* "test_data/alphabet/alphabet.odc.cpio")

(setq *cdmt-small-archive* *cdmt-odc-small-archive*)
(setq *cdmt-large-archive* *cdmt-odc-large-archive*)
(setq *cdmt-archive-format* "odc")

(defvar *cdmt-odc-untouched-small-archive* "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))
\\0\\0\\0
aa

\\0\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))
\\0\\0
aaa

\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))
\\0
aaaa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))
\\0\\0\\0
bb

\\0\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))
\\0\\0
bbb

\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))
\\0
bbbb

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))
\\0\\0\\0
cc

\\0\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))
\\0\\0
ccc

\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))
\\0
cccc

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
\\0\\0070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
"
  "The contents of the untouched small archive.")
(setq *cdmt-odc-untouched-small-archive* "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
")

(defvar *cdmt-odc-untouched-small-dired-buffer* "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
"
  "The contents of an untouched archive's dired-style buffer.")
(setq *cdmt-odc-untouched-small-dired-buffer* "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
")

(defvar *cdmt-odc-untouched-small-catalog* "((\"a\" .
\\s-+[[43252341448 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"a\"]
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 113 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aa\" .
\\s-+[[43252341474 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"aa\"]
\\s-+#<marker at 117 in alphabet_small.odc.cpio> #<marker at 233 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaa\" .
\\s-+[[43252341508 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"aaa\"]
\\s-+#<marker at 241 in alphabet_small.odc.cpio> #<marker at 357 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaa\" .
\\s-+[[43252341511 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"aaaa\"]
\\s-+#<marker at 365 in alphabet_small.odc.cpio> #<marker at 481 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaaa\" .
\\s-+[[43252341512 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"aaaaa\"]
\\s-+#<marker at 489 in alphabet_small.odc.cpio> #<marker at 605 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaaa.d\" .
\\s-+[[43252341515 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"aaaaa.d\"]
\\s-+#<marker at 613 in alphabet_small.odc.cpio> #<marker at 733 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"b\" .
\\s-+[[43252341513 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"b\"]
\\s-+#<marker at 733 in alphabet_small.odc.cpio> #<marker at 845 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bb\" .
\\s-+[[43252341514 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"bb\"]
\\s-+#<marker at 849 in alphabet_small.odc.cpio> #<marker at 965 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbb\" .
\\s-+[[43252341516 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"bbb\"]
\\s-+#<marker at 973 in alphabet_small.odc.cpio> #<marker at 1089 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbb\" .
\\s-+[[43252341517 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"bbbb\"]
\\s-+#<marker at 1097 in alphabet_small.odc.cpio> #<marker at 1213 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbbb\" .
\\s-+[[43252341518 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"bbbbb\"]
\\s-+#<marker at 1221 in alphabet_small.odc.cpio> #<marker at 1337 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbbb.d\" .
\\s-+[[43252341601 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"bbbbb.d\"]
\\s-+#<marker at 1345 in alphabet_small.odc.cpio> #<marker at 1465 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"c\" .
\\s-+[[43252341519 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"c\"]
\\s-+#<marker at 1465 in alphabet_small.odc.cpio> #<marker at 1577 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"cc\" .
\\s-+[[43252341600 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"cc\"]
\\s-+#<marker at 1581 in alphabet_small.odc.cpio> #<marker at 1697 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccc\" .
\\s-+[[43252341602 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"ccc\"]
\\s-+#<marker at 1705 in alphabet_small.odc.cpio> #<marker at 1821 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"cccc\" .
\\s-+[[43252341603 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"cccc\"]
\\s-+#<marker at 1829 in alphabet_small.odc.cpio> #<marker at 1945 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccccc\" .
\\s-+[[43252341604 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"ccccc\"]
\\s-+#<marker at 1953 in alphabet_small.odc.cpio> #<marker at 2069 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccccc.d\" .
\\s-+[[43252341607 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"ccccc.d\"]
\\s-+#<marker at 2077 in alphabet_small.odc.cpio> #<marker at 2197 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
"
  "An string representing an untouched catalog.")
(setq *cdmt-odc-untouched-small-catalog* "((\"a\" .
\\s-+[[43252341448 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"a\"]
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 113 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aa\" .
\\s-+[[43252341474 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"aa\"]
\\s-+#<marker at 117 in alphabet_small.odc.cpio> #<marker at 233 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaa\" .
\\s-+[[43252341508 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"aaa\"]
\\s-+#<marker at 241 in alphabet_small.odc.cpio> #<marker at 357 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaa\" .
\\s-+[[43252341511 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"aaaa\"]
\\s-+#<marker at 365 in alphabet_small.odc.cpio> #<marker at 481 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaaa\" .
\\s-+[[43252341512 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"aaaaa\"]
\\s-+#<marker at 489 in alphabet_small.odc.cpio> #<marker at 605 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"aaaaa.d\" .
\\s-+[[43252341515 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"aaaaa.d\"]
\\s-+#<marker at 613 in alphabet_small.odc.cpio> #<marker at 733 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"b\" .
\\s-+[[43252341513 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"b\"]
\\s-+#<marker at 733 in alphabet_small.odc.cpio> #<marker at 845 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bb\" .
\\s-+[[43252341514 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"bb\"]
\\s-+#<marker at 849 in alphabet_small.odc.cpio> #<marker at 965 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbb\" .
\\s-+[[43252341516 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"bbb\"]
\\s-+#<marker at 973 in alphabet_small.odc.cpio> #<marker at 1089 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbb\" .
\\s-+[[43252341517 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"bbbb\"]
\\s-+#<marker at 1097 in alphabet_small.odc.cpio> #<marker at 1213 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbbb\" .
\\s-+[[43252341518 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"bbbbb\"]
\\s-+#<marker at 1221 in alphabet_small.odc.cpio> #<marker at 1337 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"bbbbb.d\" .
\\s-+[[43252341601 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"bbbbb.d\"]
\\s-+#<marker at 1345 in alphabet_small.odc.cpio> #<marker at 1465 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"c\" .
\\s-+[[43252341519 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+4 253 0 0 0 2 0 \"c\"]
\\s-+#<marker at 1465 in alphabet_small.odc.cpio> #<marker at 1577 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"cc\" .
\\s-+[[43252341600 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+5 253 0 0 0 3 0 \"cc\"]
\\s-+#<marker at 1581 in alphabet_small.odc.cpio> #<marker at 1697 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccc\" .
\\s-+[[43252341602 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+6 253 0 0 0 4 0 \"ccc\"]
\\s-+#<marker at 1705 in alphabet_small.odc.cpio> #<marker at 1821 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"cccc\" .
\\s-+[[43252341603 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+7 253 0 0 0 5 0 \"cccc\"]
\\s-+#<marker at 1829 in alphabet_small.odc.cpio> #<marker at 1945 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccccc\" .
\\s-+[[43252341604 33188 1000 1000 1
\\s-+(23281 65535)
\\s-+8 253 0 0 0 6 0 \"ccccc\"]
\\s-+#<marker at 1953 in alphabet_small.odc.cpio> #<marker at 2069 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
 (\"ccccc.d\" .
\\s-+[[43252341607 16877 1000 1000 2
\\s-+(23268 65535)
\\s-+0 253 0 0 0 8 0 \"ccccc.d\"]
\\s-+#<marker at 2077 in alphabet_small.odc.cpio> #<marker at 2197 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
")

(defvar *cdmt-odc-untouched-large-archive-buffer* "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
d	(( filename ))

d

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
dd	(( filename ))

dd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ddd	(( filename ))

ddd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
dddd	(( filename ))

dddd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ddddd	(( filename ))

ddddd

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ddddd.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
e	(( filename ))

e

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ee	(( filename ))

ee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
eee	(( filename ))

eee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
eeee	(( filename ))

eeee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
eeeee	(( filename ))

eeeee

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
eeeee.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
f	(( filename ))

f

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ff	(( filename ))

ff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
fff	(( filename ))

fff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
ffff	(( filename ))

ffff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
fffff	(( filename ))

fffff

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
fffff.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
g	(( filename ))

g

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
gg	(( filename ))

gg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ggg	(( filename ))

ggg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
gggg	(( filename ))

gggg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ggggg	(( filename ))

ggggg

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ggggg.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
h	(( filename ))

h

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
hh	(( filename ))

hh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
hhh	(( filename ))

hhh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
hhhh	(( filename ))

hhhh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
hhhhh	(( filename ))

hhhhh

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
hhhhh.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
i	(( filename ))

i

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ii	(( filename ))

ii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
iii	(( filename ))

iii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
iiii	(( filename ))

iiii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
iiiii	(( filename ))

iiiii

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
iiiii.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
j	(( filename ))

j

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
jj	(( filename ))

jj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
jjj	(( filename ))

jjj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
jjjj	(( filename ))

jjjj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
jjjjj	(( filename ))

jjjjj

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
jjjjj.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
k	(( filename ))

k

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
kk	(( filename ))

kk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
kkk	(( filename ))

kkk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
kkkk	(( filename ))

kkkk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
kkkkk	(( filename ))

kkkkk

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
kkkkk.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
l	(( filename ))

l

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ll	(( filename ))

ll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
lll	(( filename ))

lll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
llll	(( filename ))

llll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
lllll	(( filename ))

lllll

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
lllll.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
m	(( filename ))

m

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
mm	(( filename ))

mm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
mmm	(( filename ))

mmm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
mmmm	(( filename ))

mmmm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
mmmmm	(( filename ))

mmmmm

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
mmmmm.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
n	(( filename ))

n

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
nn	(( filename ))

nn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
nnn	(( filename ))

nnn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
nnnn	(( filename ))

nnnn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
nnnnn	(( filename ))

nnnnn

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
nnnnn.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
o	(( filename ))

o

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
oo	(( filename ))

oo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ooo	(( filename ))

ooo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
oooo	(( filename ))

oooo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ooooo	(( filename ))

ooooo

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ooooo.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
p	(( filename ))

p

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
pp	(( filename ))

pp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ppp	(( filename ))

ppp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
pppp	(( filename ))

pppp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ppppp	(( filename ))

ppppp

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ppppp.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
q	(( filename ))

q

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
qq	(( filename ))

qq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
qqq	(( filename ))

qqq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
qqqq	(( filename ))

qqqq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
qqqqq	(( filename ))

qqqqq

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
qqqqq.d	(( filename ))
070707	(( magic    ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
r	(( filename ))

r

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
rr	(( filename ))

rr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
rrr	(( filename ))

rrr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
rrrr	(( filename ))

rrrr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
rrrrr	(( filename ))

rrrrr

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
rrrrr.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
s	(( filename ))

s

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ss	(( filename ))

ss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
sss	(( filename ))

sss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
ssss	(( filename ))

ssss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
sssss	(( filename ))

sssss

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
sssss.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
t	(( filename ))

t

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
tt	(( filename ))

tt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ttt	(( filename ))

ttt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
tttt	(( filename ))

tttt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ttttt	(( filename ))

ttttt

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ttttt.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
u	(( filename ))

u

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
uu	(( filename ))

uu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
uuu	(( filename ))

uuu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
uuuu	(( filename ))

uuuu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
uuuuu	(( filename ))

uuuuu

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
uuuuu.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
v	(( filename ))

v

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
vv	(( filename ))

vv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
vvv	(( filename ))

vvv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
vvvv	(( filename ))

vvvv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
vvvvv	(( filename ))

vvvvv

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
vvvvv.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
w	(( filename ))

w

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ww	(( filename ))

ww

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
www	(( filename ))

www

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
wwww	(( filename ))

wwww

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
wwwww	(( filename ))

wwwww

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
wwwww.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
x	(( filename ))

x

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
xx	(( filename ))

xx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
xxx	(( filename ))

xxx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
xxxx	(( filename ))

xxxx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
xxxxx	(( filename ))

xxxxx

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
xxxxx.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
y	(( filename ))

y

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
yy	(( filename ))

yy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
yyy	(( filename ))

yyy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
yyyy	(( filename ))

yyyy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
yyyyy	(( filename ))

yyyyy

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
yyyyy.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
z	(( filename ))

z

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
zz	(( filename ))

zz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
zzz	(( filename ))

zzz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
zzzz	(( filename ))

zzzz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
zzzzz	(( filename ))

zzzzz

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
zzzzz.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))

"
  "Contents of the untouched large cpio archive buffer.")
(setq *cdmt-odc-untouched-large-archive-buffer* "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
d	(( filename ))

d

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
dd	(( filename ))

dd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ddd	(( filename ))

ddd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
dddd	(( filename ))

dddd

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ddddd	(( filename ))

ddddd

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ddddd.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
e	(( filename ))

e

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ee	(( filename ))

ee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
eee	(( filename ))

eee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
eeee	(( filename ))

eeee

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
eeeee	(( filename ))

eeeee

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
eeeee.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
f	(( filename ))

f

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ff	(( filename ))

ff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
fff	(( filename ))

fff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
ffff	(( filename ))

ffff

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
fffff	(( filename ))

fffff

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
fffff.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
g	(( filename ))

g

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
gg	(( filename ))

gg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ggg	(( filename ))

ggg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
gggg	(( filename ))

gggg

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ggggg	(( filename ))

ggggg

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ggggg.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
h	(( filename ))

h

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
hh	(( filename ))

hh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
hhh	(( filename ))

hhh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
hhhh	(( filename ))

hhhh

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
hhhhh	(( filename ))

hhhhh

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
hhhhh.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
i	(( filename ))

i

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ii	(( filename ))

ii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
iii	(( filename ))

iii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
iiii	(( filename ))

iiii

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
iiiii	(( filename ))

iiiii

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
iiiii.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
j	(( filename ))

j

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
jj	(( filename ))

jj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
jjj	(( filename ))

jjj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
jjjj	(( filename ))

jjjj

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
jjjjj	(( filename ))

jjjjj

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
jjjjj.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
k	(( filename ))

k

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
kk	(( filename ))

kk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
kkk	(( filename ))

kkk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
kkkk	(( filename ))

kkkk

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
kkkkk	(( filename ))

kkkkk

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
kkkkk.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
l	(( filename ))

l

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ll	(( filename ))

ll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
lll	(( filename ))

lll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
llll	(( filename ))

llll

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
lllll	(( filename ))

lllll

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
lllll.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
m	(( filename ))

m

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
mm	(( filename ))

mm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
mmm	(( filename ))

mmm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
mmmm	(( filename ))

mmmm

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
mmmmm	(( filename ))

mmmmm

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
mmmmm.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
n	(( filename ))

n

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
nn	(( filename ))

nn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
nnn	(( filename ))

nnn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
nnnn	(( filename ))

nnnn

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
nnnnn	(( filename ))

nnnnn

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
nnnnn.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
o	(( filename ))

o

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
oo	(( filename ))

oo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ooo	(( filename ))

ooo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
oooo	(( filename ))

oooo

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ooooo	(( filename ))

ooooo

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ooooo.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
p	(( filename ))

p

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
pp	(( filename ))

pp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ppp	(( filename ))

ppp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
pppp	(( filename ))

pppp

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ppppp	(( filename ))

ppppp

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ppppp.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
q	(( filename ))

q

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
qq	(( filename ))

qq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
qqq	(( filename ))

qqq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
qqqq	(( filename ))

qqqq

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
qqqqq	(( filename ))

qqqqq

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
qqqqq.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
r	(( filename ))

r

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
rr	(( filename ))

rr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
rrr	(( filename ))

rrr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
rrrr	(( filename ))

rrrr

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
rrrrr	(( filename ))

rrrrr

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
rrrrr.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
s	(( filename ))

s

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ss	(( filename ))

ss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
sss	(( filename ))

sss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
ssss	(( filename ))

ssss

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
sssss	(( filename ))

sssss

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
sssss.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
t	(( filename ))

t

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
tt	(( filename ))

tt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ttt	(( filename ))

ttt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
tttt	(( filename ))

tttt

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ttttt	(( filename ))

ttttt

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ttttt.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
u	(( filename ))

u

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
uu	(( filename ))

uu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
uuu	(( filename ))

uuu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
uuuu	(( filename ))

uuuu

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
uuuuu	(( filename ))

uuuuu

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
uuuuu.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
v	(( filename ))

v

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
vv	(( filename ))

vv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
vvv	(( filename ))

vvv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
vvvv	(( filename ))

vvvv

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
vvvvv	(( filename ))

vvvvv

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
vvvvv.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
w	(( filename ))

w

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
ww	(( filename ))

ww

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
www	(( filename ))

www

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
wwww	(( filename ))

wwww

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
wwwww	(( filename ))

wwwww

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
wwwww.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
x	(( filename ))

x

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
xx	(( filename ))

xx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
xxx	(( filename ))

xxx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
xxxx	(( filename ))

xxxx

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
xxxxx	(( filename ))

xxxxx

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
xxxxx.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
y	(( filename ))

y

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
yy	(( filename ))

yy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
yyy	(( filename ))

yyy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
yyyy	(( filename ))

yyyy

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
yyyyy	(( filename ))

yyyyy

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
yyyyy.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
z	(( filename ))

z

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
zz	(( filename ))

zz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
zzz	(( filename ))

zzz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
zzzz	(( filename ))

zzzz

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
zzzzz	(( filename ))

zzzzz

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
zzzzz.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
")

(defvar *cdmt-odc-untouched-large-dired-buffer* "CPIO archive: alphabet.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dddd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddddd
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddddd.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} e
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeeee
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeeee.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} f
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ffff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fffff
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fffff.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} g
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} gg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} gggg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggggg
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggggg.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} h
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhhh
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhhh.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} i
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiiii
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiiii.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} j
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjjj
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjjj.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} k
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkkk
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkkk.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} l
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} llll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lllll
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lllll.d
.+"					;emacs barfs if it's much longer than this.
  "Contents of an untouched cpio-dired directory for the large cpio archive.")
(setq *cdmt-odc-untouched-large-dired-buffer* "CPIO archive: alphabet.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dddd
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddddd
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ddddd.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} e
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeee
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeeee
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} eeeee.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} f
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ffff
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fffff
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} fffff.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} g
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} gg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} gggg
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggggg
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ggggg.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} h
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhh
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhhh
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} hhhhh.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} i
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiii
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiiii
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} iiiii.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} j
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjj
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjjj
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} jjjjj.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} k
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkk
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkkk
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} kkkkk.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} l
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} llll
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lllll
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} lllll.d
.+
")



;;
;; Library
;; 
(defun cdmt-odc-filter-archive-contents (archive-contents)
  "Make the given ARCHIVE-CONTENTS fully printable and readable."
  (let ((fname "cdmt-odc-filter-archive-contents")
	(char-map (list (cons "\0" "\\0"))))
    (setq archive-contents (cdmt-odc-reformat-odc-headers archive-contents))
    (mapc (lambda (cm)
	    (let ((from (car cm))
		  (to (cdr cm)))
	      (setq archive-contents (cdmt-global-sub from to archive-contents))))
	  char-map)
    archive-contents))

(defun cdmt-odc-reformat-odc-headers (archive-contents)
  "Reformat the cpio odc entry headers in the given ARCHIVE-CONTENTS
So that they are human readable.
CAVEATS: \(1\) If ARCHIVE-CONTENTS contains entries that contain entry headers,
then those will also be reformatted.
\(2\) The entry names are taken to be a sequence of printable characters.
So, if NULLs have been converted to printable characters,
then the entry names will be incorrect."
  (let ((fname "cdmt-odc-reformat-odc-headers"))
    (while (string-match *cpio-odc-header-re* archive-contents)
      (setq archive-contents (concat (substring archive-contents 0 (match-beginning 0))
				     (concat (match-string-no-properties *cpio-odc-magic-re-idx*    archive-contents) "\t(( magic    ))\n")
				     (concat "DEADBE"                                                   "\t(( ino      ))\n")
				     (concat (match-string-no-properties *cpio-odc-mode-re-idx*     archive-contents) "\t(( mode     ))\n")
				     (concat (match-string-no-properties *cpio-odc-uid-re-idx*      archive-contents) "\t(( uid      ))\n")
				     (concat (match-string-no-properties *cpio-odc-gid-re-idx*      archive-contents) "\t(( gid      ))\n")
				     (concat (match-string-no-properties *cpio-odc-nlink-re-idx*    archive-contents) "\t(( nlink    ))\n")
				     ;; Note that the mod time can change.
				     (concat "DEADBE"                                                   "\t(( mtime    ))\n")
				     (concat (match-string-no-properties *cpio-odc-filesize-re-idx* archive-contents) "\t(( filesize ))\n")
				     (concat "DEADBE"                                                   "\t(( dev maj  ))\n")
				     (concat "DEADBE"                                                   "\t(( dev min  ))\n")
				     (concat "DEADBE"                                                   "\t(( rdev maj ))\n")
				     (concat "DEADBE"                                                   "\t(( rdev min ))\n")
				     (concat (match-string-no-properties *cpio-odc-namesize-re-idx* archive-contents) "\t(( namesize ))\n")
				     (concat "000000"                                                   "\t(( chksum   ))\n")
				     (concat (match-string-no-properties *cpio-odc-filename-re-idx* archive-contents) "\t(( filename ))\n")
				     (substring archive-contents (match-end 0)))))
    (concat archive-contents "\n")))



;; 
;; Tests
;; 

;; N.B. cdmt-odc- = cpio-dired-mode-test-

(defvar run-dir default-directory)

(custom-set-variables (list 'cpio-try-names nil))

;; All tests use M-x cpio-dired-kill.
;; (ert-deftest cdmt-odc-cpio-dired-kill () ;✓
;;   "Test the function of M-x cpio-dired-kill."
;;   (let ((test-name "cdmt-odc-cpio-dired-kill")
;;         (cpio-archive-buffer)
;;         (cpio-archive-buffer-contents)
;;         (cpio-dired-buffer)
;;         (cpio-dired-buffer-contents))
;; 
;;     (cdmt-reset 'make)
;; 
;;     (cpio-dired-kill)
;; 
;;     (message "%s(): Dired style buffer should not be live." test-name)
;;     (should (not (buffer-live-p cpio-dired-buffer)))
;;     (message "%s(): Archive buffer should not be live." test-name)
;;     (should (not (buffer-live-p cpio-archive-buffer)))))

  (ert-deftest cdmt-odc-cpio-dired-do-isearch ()
    "Test cpio-dired-do-isearch.
cpio-dired-do-isearch is not yet implemented -- expect an error."
    (should-error (cpio-dired-do-isearch)
		  :type 'error))

  (ert-deftest cdmt-odc-cpio-dired-do-isearch-regexp ()
    "Test cpio-dired-do-isearch-regexp.
cpio-dired-do-isearch-regexp is not yet implemented -- expect an error."
    (should-error (cpio-dired-do-isearch-regexp)
		  :type 'error))

  (ert-deftest cdmt-odc-cpio-dired-isearch-entry-names ()
    "Test cpio-dired-isearch-entry-names.
cpio-dired-isearch-entry-names is not yet implemented -- expect an error."
    (should-error (cpio-dired-isearch-entry-names)
		  :type 'error))

  (ert-deftest cdmt-odc-cpio-dired-isearch-entry-names-regexp ()
    "Test cpio-dired-isearch-entry-names-regexp.
cpio-dired-isearch-entry-names-regexp is not yet implemented -- expect an error."
    (should-error (cpio-dired-isearch-entry-names-regexp)
		  :type 'error))

;;;;;;;; This gets an end-of-buffer error under ERT.
;;;;;;;; (ert-deftest cdmt-odc-cpio-dired-save-archive-0 () ;✓
;;;;;;;;   "Test the function of M-x cpio-dired-save-archive."
;;;;;;;;   (let ((test-name "cdmt-odc-cpio-dired-save-archive")
;;;;;;;;         (cpio-archive-buffer)
;;;;;;;; 	(cpio-archive-buffer-contents-before)
;;;;;;;;         (cpio-archive-buffer-contents)
;;;;;;;;         (cpio-dired-buffer)
;;;;;;;;         (cpio-dired-buffer-contents-before)
;;;;;;;;         (cpio-dired-buffer-contents)
;;;;;;;;         )
;;;;;;;;     (cdmt-reset 'make)

;;;;;;;;     (progn (goto-char (point-min))
;;;;;;;; 	   (re-search-forward " aa$" (point-max))
;;;;;;;; 	   (cpio-dired-do-delete 1)
;;;;;;;; 	   (setq cpio-archive-buffer-contents-before
;;;;;;;; 		 (cdmt-odc-filter-archive-contents (with-current-buffer cpio-archive-buffer
;;;;;;;; 						 (buffer-substring-no-properties (point-min) (point-max)))))
;;;;;;;; 	   (setq cpio-dired-buffer-contents-before (with-current-buffer cpio-dired-buffer
;;;;;;;; 						     (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;;;;     (should (progn (message "%s(): Archive buffer should be modified. " test-name)
;;;;;;;; 		 (buffer-modified-p cpio-archive-buffer)))
;;;;;;;;     (should (progn (message "%s(): test-name Archive buffer should be missing exactly the entry for aa."
;;;;;;;; 		 (string-equal "070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; a	(( filename ))

;;;;;;;; a

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaa	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; aaa

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaa	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaaa

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa	(( filename ))

;;;;;;;; aaaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; b	(( filename ))

;;;;;;;; b

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bb	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; bb

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbb	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; bbb

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbb	(( filename ))
;;;;;;;; \\0
;;;;;;;; bbbb

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb	(( filename ))

;;;;;;;; bbbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; c	(( filename ))

;;;;;;;; c

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cc	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; cc

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccc	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; ccc

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; cccc

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc	(( filename ))

;;;;;;;; ccccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 000000	(( mode     ))
;;;;;;;; 000000	(( uid      ))
;;;;;;;; 000000	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000013	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; TRAILER!!!	(( filename ))
;;;;;;;; \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0" cpio-archive-buffer-contents-before)))
;;;;;;;;     (should (progn (message "%s(): Checking dired-style buffer before saving." test-name)
;;;;;;;; 		 (string-match "CPIO archive: alphabet_small.odc.cpio:

;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
;;;;;;;; " cpio-dired-buffer-contents-before)))

;;;;;;;;     (progn (cpio-dired-save-archive)
;;;;;;;; 	   (setq cpio-archive-buffer-contents
;;;;;;;; 		 (cdmt-odc-filter-archive-contents 
;;;;;;;; 		  (with-current-buffer cpio-archive-buffer
;;;;;;;; 		    (buffer-substring-no-properties (point-min) (point-max)))))
;;;;;;;; 	   (setq cpio-dired-buffer-contents
;;;;;;;; 		 (with-current-buffer cpio-dired-buffer
;;;;;;;; 		   (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min)(point)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (progn (message "%s(): Archive buffer should no longer be modified." test-name)
;;;;;;;; 		 (not (buffer-modified-p cpio-archive-buffer))))
;;;;;;;;     (should (progn (message "%s(): Checking the archive buffer after saving." test-name)
;;;;;;;; 		 (string-equal "070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; a	(( filename ))

;;;;;;;; a

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaa	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; aaa

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaa	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaaa

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa	(( filename ))

;;;;;;;; aaaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; b	(( filename ))

;;;;;;;; b

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bb	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; bb

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbb	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; bbb

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbb	(( filename ))
;;;;;;;; \\0
;;;;;;;; bbbb

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb	(( filename ))

;;;;;;;; bbbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; c	(( filename ))

;;;;;;;; c

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cc	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; cc

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccc	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; ccc

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; cccc

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc	(( filename ))

;;;;;;;; ccccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 000000	(( mode     ))
;;;;;;;; 000000	(( uid      ))
;;;;;;;; 000000	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000013	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; TRAILER!!!	(( filename ))
;;;;;;;; \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0" cpio-archive-buffer-contents)))

;;;;;;;;     (should (progn (message "%s(): Checking the dired-style buffer after saving." test-name)
;;;;;;;; 		 (string-match "CPIO archive: alphabet_small.odc.cpio:

;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
;;;;;;;; " cpio-dired-buffer-contents)))

;;;;;;;;     ;; The archive strings should be identical up to the TRAILER!!! padding.
;;;;;;;;     ;; NO! Padding after any added, deleted or changed entry will also change.
;;;;;;;;     ;; (string-match "TRAILER!!!" cpio-archive-buffer-contents-before)
;;;;;;;;     ;; (setq cpio-archive-buffer-contents-before (substring cpio-archive-buffer-contents-before 0 (match-end 0)))
;;;;;;;;     ;; (string-match "TRAILER!!!" cpio-archive-buffer-contents)
;;;;;;;;     ;; (setq cpio-archive-buffer-contents (substring cpio-archive-buffer-contents 0 (match-end 0)))
;;;;;;;;     ;; (should (string-equal cpio-archive-buffer-contents-before cpio-archive-buffer-contents))

;;;;;;;;     (should (progn (message "%s(): The dired style buffer should not have changed." test-name)
;;;;;;;; 		 (string-equal cpio-dired-buffer-contents-before cpio-dired-buffer-contents)))

;;;;;;;;     (cdmt-reset)

;;;;;;;;     (progn (goto-char (point-min))
;;;;;;;; 	   (re-search-forward " aaaa$" (point-max))
;;;;;;;; 	   (setq unread-command-events (listify-key-sequence "dddd\n"))
;;;;;;;; 	   (cpio-dired-do-rename 1)
;;;;;;;; 	   (cpio-dired-save-archive)
;;;;;;;; 	   (setq cpio-archive-buffer-contents
;;;;;;;; 		 (cdmt-odc-filter-archive-contents
;;;;;;;; 		  (with-current-buffer cpio-archive-buffer
;;;;;;;; 		    (buffer-substring-no-properties (point-min) (point-max)))))
;;;;;;;; 	   (setq cpio-dired-buffer-contents
;;;;;;;; 		 (with-current-buffer cpio-dired-buffer
;;;;;;;; 		   (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (progn (message "%s(): Expecting the standard archive with aaaa moved to ddddd." test-name)
;;;;;;;; 		 (string-equal "070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; a	(( filename ))

;;;;;;;; a

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaa	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; aaa

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa	(( filename ))

;;;;;;;; aaaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; b	(( filename ))

;;;;;;;; b

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bb	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; bb

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbb	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; bbb

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbb	(( filename ))
;;;;;;;; \\0
;;;;;;;; bbbb

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb	(( filename ))

;;;;;;;; bbbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; c	(( filename ))

;;;;;;;; c

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))

;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cc	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; cc

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccc	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; ccc

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; cccc

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc	(( filename ))

;;;;;;;; ccccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; dddd	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaaa

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 000000	(( mode     ))
;;;;;;;; 000000	(( uid      ))
;;;;;;;; 000000	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000013	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; TRAILER!!!	(( filename ))
;;;;;;;; \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0" cpio-archive-buffer-contents)))

;;;;;;;;     (should (progn (message "%s(): Expecting a dired style buffer without aaaa." test-name)
;;;;;;;; 		 (string-match "CPIO archive: alphabet_small.odc.cpio:

;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dddd
;;;;;;;; " cpio-dired-buffer-contents)))

;;;;;;;;     (cdmt-reset)

;;;;;;;;     (progn (goto-char (point-min))
;;;;;;;; 	   (re-search-forward " b$" (point-max))
;;;;;;;; 	   (cpio-dired-mark 4)
;;;;;;;; 	   (setq unread-command-events (listify-key-sequence "d\n"))
;;;;;;;; 	   (cpio-dired-do-rename 1)
;;;;;;;; 	   (cpio-dired-save-archive)
;;;;;;;; 	   (setq cpio-archive-buffer-contents
;;;;;;;; 		 (cdmt-odc-filter-archive-contents
;;;;;;;; 		  (with-current-buffer cpio-archive-buffer
;;;;;;;; 		    (buffer-substring-no-properties (point-min) (point-max)))))
;;;;;;;; 	   (setq cpio-dired-buffer-contents
;;;;;;;; 		 (with-current-buffer cpio-dired-buffer
;;;;;;;; 		   (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (progn (message "%s(): Expecting a small archive with d/b, d/bb, d/bbb, d/bbbb." test-name)
;;;;;;;; 		 (string-equal "070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; a	(( filename ))

;;;;;;;; a

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaa	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; aaa

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa	(( filename ))

;;;;;;;; aaaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb	(( filename ))

;;;;;;;; bbbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; c	(( filename ))

;;;;;;;; c

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cc	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; cc

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccc	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; ccc

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; cccc

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc	(( filename ))

;;;;;;;; ccccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; dddd	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaaa

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000007	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; d/bbbb	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; bbbb

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; d/bbb	(( filename ))

;;;;;;;; bbb

;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; d/bb	(( filename ))
;;;;;;;; \\0
;;;;;;;; bb

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000004	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; d/b	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; b

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 000000	(( mode     ))
;;;;;;;; 000000	(( uid      ))
;;;;;;;; 000000	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000013	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; TRAILER!!!	(( filename ))
;;;;;;;; \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0" cpio-archive-buffer-contents)))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (progn (message "%s(): Looking for a small dired-style buffer with d/b, d/bb, d/bbb, d/bbbb" test-name)
;;;;;;;; 		 (string-match "CPIO archive: alphabet_small.odc.cpio:

;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dddd
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d/bbbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d/bbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d/bb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d/b
;;;;;;;; " cpio-dired-buffer-contents)))

;;;;;;;;     (cdmt-reset)

;;;;;;;;     (progn (cpio-dired-mark-entries-regexp "\\`...\\'")
;;;;;;;; 	   (setq unread-command-events (listify-key-sequence "newDirectory\n"))
;;;;;;;; 	   ;; HEREHERE This rename does something wrong.
;;;;;;;; 	   (cpio-dired-do-rename 1)
;;;;;;;; 	   (cpio-dired-save-archive)
;;;;;;;; 	   (setq cpio-archive-buffer-contents
;;;;;;;; 		 (cdmt-odc-filter-archive-contents
;;;;;;;; 		  (with-current-buffer cpio-archive-buffer
;;;;;;;; 		    (buffer-substring-no-properties (point-min) (point-max)))))
;;;;;;;; 	   (setq cpio-dired-buffer-contents
;;;;;;;; 		 (with-current-buffer cpio-dired-buffer
;;;;;;;; 		   (buffer-substring-no-properties (point-min) (point-max)))))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (string-equal "070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; a	(( filename ))

;;;;;;;; a

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa	(( filename ))

;;;;;;;; aaaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; aaaaa.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb	(( filename ))

;;;;;;;; bbbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; bbbbb.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000002	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; c	(( filename ))

;;;;;;;; c

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000003	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cc	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; cc

;;;;;;;; \\0\\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; cccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; cccc

;;;;;;;; \\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000010	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000006	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc	(( filename ))

;;;;;;;; ccccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 040755	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000002	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000010	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; ccccc.d	(( filename ))
;;;;;;;; \\0\\0070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000005	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; dddd	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000007	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000022	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/bbbb	(( filename ))

;;;;;;;; bbbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000021	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/bbb	(( filename ))
;;;;;;;; \\0
;;;;;;;; bbb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000005	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000020	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/bb	(( filename ))
;;;;;;;; \\0\\0
;;;;;;;; bb

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000004	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000017	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/b	(( filename ))
;;;;;;;; \\0\\0\\0
;;;;;;;; b

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000021	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/ccc	(( filename ))
;;;;;;;; \\0
;;;;;;;; ccc

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 100644	(( mode     ))
;;;;;;;; 001750	(( uid      ))
;;;;;;;; 001750	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000006	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000021	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; newDirectory/aaa	(( filename ))
;;;;;;;; \\0
;;;;;;;; aaa

;;;;;;;; 070707	(( magic    ))
;;;;;;;; DEADBE	(( ino      ))
;;;;;;;; 000000	(( mode     ))
;;;;;;;; 000000	(( uid      ))
;;;;;;;; 000000	(( gid      ))
;;;;;;;; 000001	(( nlink    ))
;;;;;;;; DEADBE	(( mtime    ))
;;;;;;;; 00000000000	(( filesize ))
;;;;;;;; DEADBE	(( dev maj  ))
;;;;;;;; DEADBE	(( dev min  ))
;;;;;;;; DEADBE	(( rdev maj ))
;;;;;;;; DEADBE	(( rdev min ))
;;;;;;;; 000013	(( namesize ))
;;;;;;;; 000000	(( chksum   ))
;;;;;;;; TRAILER!!!	(( filename ))
;;;;;;;; \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0" cpio-archive-buffer-contents))

;;;;;;;;     (should (= 0 1))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     (should (string-match "CPIO archive: alphabet_small.odc.cpio:

;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
;;;;;;;;   drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} dddd
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/bbbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/bbb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/bb
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/b
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/ccc
;;;;;;;;   -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaa
;;;;;;;; " cpio-dired-buffer-contents))

;;;;;;;;     (should (= 0 1))

;;;;;;;;     ;; (cdmt-odc-do-cpio-id (count-lines (point-min) (point-max)) (file-name-nondirectory *cdmt-odc-small-archive*))

;;;;;;;;     ))

  (ert-deftest cdmt-odc-cpio-dired-add-entry ()
    "Test cpio-dired-add-entry.
cpio-dired-add-entry is not yet implemented -- expect an error."
    (should-error (cpio-dired-add-entry)
		  :type 'error))

  (ert-deftest cdmt-odc-cpio-dired-change-marks ()
    "Test cpio-dired-change-marks.
cpio-dired-change-marks is not yet implemented -- expect an error."
    (should-error (cpio-dired-change-marks)
		  :type 'error))

  (ert-deftest cdmt-odc-cpio-dired-clean-directory ()
    "Test cpio-dired-clean-directory.
cpio-dired-clean-directory is not yet implemented -- expect an error."
    (should-error (cpio-dired-clean-directory)
		  :type 'error))

(ert-deftest cdmt-odc-cpio-dired-copy-entry-name-as-kill ()
  (should-error (cpio-dired-copy-entry-name-as-kill 1)
		:type 'error))

;;;; (ert-deftest NOT-YET-cdmt-odc-cpio-dired-copy-entry-name-as-kill ()
;;;;   "Test cpio-dired-copy-entry-name-as-kill.
;;;; cpio-dired-copy-entry-name-as-kill is not yet implemented -- expect an error."
;;;;   (let ((test-name "cdmt-odc-cpio-dired-copy-entry-name-as-kill")
;;;; 	  (cpio-archive-buffer)
;;;; 	  (cpio-archive-buffer-contents)
;;;; 	  (cpio-dired-buffer)
;;;; 	  (cpio-dired-buffer-contents)
;;;; 	  (cpio-contents-buffer-name)
;;;; 	  (cpio-contents-buffer)
;;;; 	  (cpio-contents-buffer-string)
;;;; 	  (cpio-contents-window)
;;;; 	  (entry-name)
;;;; 	  (current-kill-before)
;;;; 	  (kill-ring-before)
;;;; 	  (entry-names)
;;;; 	  (interprogram-paste-function nil))
;;;;       (cdmt-reset 'make)
;;;; 
;;;;       (progn (setq current-kill-before (current-kill 0 'do-not-move))
;;;; 	     (cpio-dired-next-line 2)
;;;; 	     (push (cpio-dired-get-entry-name) entry-names)
;;;; 	     (cpio-dired-copy-entry-name-as-kill 1))
;;;; 
;;;;       (while entry-names
;;;; 	(should (string-equal (current-kill 0) (pop entry-names)))
;;;; 	(current-kill 1))
;;;;       ;; Use (equal) here because the kill ring could have been empty.
;;;;       (should (equal (current-kill 0) current-kill-before))
;;;; 
;;;;       (progn (cpio-dired-next-line 2)
;;;; 	     (cpio-dired-copy-entry-name-as-kill 4)
;;;; 	     (save-excursion
;;;; 	       (let ((i 0))
;;;; 		 (while (< i 4)
;;;; 		   (push (cpio-dired-get-entry-name) entry-names)
;;;; 		   (cpio-dired-next-line 1)
;;;; 		   (setq i (1+ i))))))
;;;; 
;;;;       (while entry-names
;;;; 	(should (string-equal (current-kill 0) (pop entry-names)))
;;;; 	(current-kill 1))
;;;;       ;; Use (equal) here because the kill ring could have been empty.
;;;;       (should (equal (current-kill 0) current-kill-before))))

(ert-deftest cdmt-odc-cpio-dired-diff ()
  "Test cpio-dired-diff) ;.
cpio-dired-diff) ; is not yet implemented -- expect an error."
  (should-error (cpio-dired-diff) ;)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-display-entry () ;✓
  "Test the function of M-x cpio-dired-display-entry."
  (let ((test-name "cdmt-odc-cpio-dired-display-entry")
	(cpio-archive-buffer)
	(cpio-archive-buffer-contents)
	(cpio-dired-buffer)
	(cpio-dired-buffer-contents)
	(cpio-contents-buffer-name)
	(cpio-contents-buffer)
	(cpio-contents-buffer-string)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(cpio-contents-window)
	(entry-name))
    (cdmt-reset 'make)
    
    (set-buffer (setq cpio-dired-buffer (get-buffer (cpio-dired-buffer-name *cdmt-odc-small-archive*))))
    
    (progn (setq cpio-catalog-contents-before (format "%s" (pp (cpio-catalog))))
	   (setq entry-name "aaa")
	   (goto-char (point-min))
	   (cpio-dired-goto-entry entry-name)
	   
	   (cpio-dired-display-entry)
	   
	   ;; (cpio-dired-display-entry) changes the current buffer.
	   (with-current-buffer cpio-dired-buffer
	     (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name entry-name)))
	     (setq cpio-contents-buffer-string (with-current-buffer cpio-contents-buffer
						 (buffer-substring-no-properties (point-min)
										 (point-max))))
	     (setq cpio-contents-window (get-buffer-window cpio-contents-buffer))
	     (setq cpio-archive-buffer-contents
		   (cdmt-odc-filter-archive-contents
		    (with-current-buffer cpio-archive-buffer
		      (buffer-substring-no-properties (point-min) (point-max)))))
	     (setq cpio-dired-buffer-contents
		   (with-current-buffer cpio-dired-buffer
		     (buffer-substring-no-properties (point-min) (point-max))))
	     (setq cpio-catalog-contents-after (format "%s" (pp (cpio-catalog))))))
    
    (with-current-buffer cpio-dired-buffer
      (message "%s(): Viewing an entry should not change the archive buffer." test-name)
      (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
      (message "%s(): Viewing an entry should not change the dired-style buffer." test-name)
      (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
      (message "%s(): The contents buffer should not be null." test-name)
      (should (not (null cpio-contents-buffer)))
      (message "%s(): The contents buffer should be live." test-name)
      (should (buffer-live-p cpio-contents-buffer))
      (message "%s(): Check the entry's contents buffer." test-name)
      (should (string-equal cpio-contents-buffer-string "\naaa\n\n"))
      (message "%s(): The entry's contents' window should be live." test-name)
      (should (window-live-p cpio-contents-window))
      (message "%s(): Expecting no change to the catalog." test-name)
      (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after)))
    
    (cdmt-reset)
    
    (progn (setq cpio-catalog-contents-before (format "%s" (pp (cpio-catalog))))
	   (setq entry-name "ccc")
	   (goto-char (point-min))
	   (re-search-forward " ccc$" (point-max))
	   (cpio-dired-display-entry)
	   
	   (with-current-buffer cpio-dired-buffer
	     (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name entry-name)))
	     (setq cpio-contents-buffer-string (with-current-buffer cpio-contents-buffer
						 (buffer-substring-no-properties (point-min)
										 (point-max))))
	     (setq cpio-contents-window (get-buffer-window cpio-contents-buffer))
	     (setq cpio-archive-buffer-contents
		   (cdmt-odc-filter-archive-contents
		    (with-current-buffer cpio-archive-buffer
		      (buffer-substring-no-properties (point-min) (point-max)))))
	     (setq cpio-dired-buffer-contents
		   (with-current-buffer cpio-dired-buffer
		     (buffer-substring-no-properties (point-min) (point-max))))
	     (setq cpio-catalog-contents-after (format "%s" (pp (cpio-catalog))))))
    
    (with-current-buffer cpio-dired-buffer
      (message "%s(): Checking the archive buffer." test-name)
      (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
      (message "%s(): Checking the dired-style buffer." test-name)
      (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
      (should (not (null cpio-contents-buffer)))
      (should (buffer-live-p cpio-contents-buffer))
      (should (string-equal cpio-contents-buffer-string "\nccc\n\n"))
      (should (window-live-p cpio-contents-window))
      (message "%s(): Expecting no change to the catalog." test-name)
      (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after)))))

(ert-deftest cdmt-odc-cpio-dired-do-async-shell-command ()
  "Test cpio-dired-do-async-shell-command) ;.
cpio-dired-do-async-shell-command) ; is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-async-shell-command)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-chgrp () ;✓
  "Test the function of M-x cpio-dired-do-chgrp."
  (let ((test-name "cdmt-odc-cpio-dired-do-chgrp")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (format "%s" (pp (cpio-catalog))))
	   (cpio-dired-move-to-first-entry)
	   (setq unread-command-events (listify-key-sequence "9999\n"))
	   (cpio-dired-do-chgrp 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (format "%s" (pp (cpio-catalog)))))

    (message "%s(): Expecting an unchanged archive. (8814)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting 'a' to have group 9999." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  9999        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))
    
    (message "%s(): Expecting a catalog with the first entry having group 9999." test-name)
    (should (string-match "((\"a\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 9999 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"a\"]
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"aa\"]
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"aaa\"]
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"aaaa\"]
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"aaaaa\"]
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"aaaaa\.d\"]
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"b\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"b\"]
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"bb\"]
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"bbb\"]
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"bbbb\"]
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"bbbbb\"]
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"bbbbb\.d\"]
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"c\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"c\"]
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"cc\"]
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"ccc\"]
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"cccc\"]
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"ccccc\"]
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"ccccc\.d\"]
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified]))
" cpio-catalog-contents-after))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (format "%s" (pp (cpio-catalog))))
	   (setq unread-command-events (listify-key-sequence "8888\n"))
	   (cpio-dired-do-chgrp 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (format "%s" (pp (cpio-catalog)))))
    
    (message "%s(): The archive buffer doesn't change until saving." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting the first 4 entries to have group 8888." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  8888        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  8888        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  8888        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  8888        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))
    
    (message "%s(): Expecting an archive with 4 entries having group 8888." test-name)
    (should (string-match"((\"a\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 8888 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"a\"]
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 8888 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"aa\"]
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 8888 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"aaa\"]
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 8888 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"aaaa\"]
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"aaaaa\"]
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"aaaaa\.d\"]
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"b\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"b\"]
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"bb\"]
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"bbb\"]
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"bbbb\"]
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"bbbbb\"]
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"bbbbb\.d\"]
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"c\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"c\"]
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"cc\"]
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"ccc\"]
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"cccc\"]
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"ccccc\"]
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"ccccc\.d\"]
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified]))
" cpio-catalog-contents-after))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (format "%s" (pp (cpio-catalog))))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "7777\n"))
	   (cpio-dired-do-chgrp 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (format "%s" (pp (cpio-catalog)))))

    (message "%s(): The archive is not changed until saved. (8894)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting \`...\' to have group 7777." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  7777        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  7777        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  7777        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting \`...\' to have group 7777." test-name)
    (should (string-match "((\"a\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"a\"]
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"aa\"]
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 7777 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"aaa\"]
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"aaaa\"]
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"aaaaa\"]
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"aaaaa\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"aaaaa\.d\"]
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"b\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"b\"]
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"bb\"]
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 7777 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"bbb\"]
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"bbbb\"]
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"bbbbb\"]
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"bbbbb\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"bbbbb\.d\"]
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"c\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 \"c\"]
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 \"cc\"]
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ 7777 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 \"ccc\"]
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"cccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 \"cccc\"]
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\" \.
\\s-+\[\[[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 \"ccccc\"]
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified])
\\s-+(\"ccccc\.d\" \.
\\s-+\[\[[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 \"ccccc\.d\"]
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified]))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-chmod ()
  "Test cpio-dired-do-chmod."
  (let ((test-name "cmt-cpio-dired-do-chmod")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)
    
    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq unread-command-events (listify-key-sequence "0755\n"))
	   (cpio-dired-do-chmod 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))
    
    (message "%s(): Expecting the first entry to have mode -rwxr-xr-x." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rwxr-xr-x   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))
    
    (message "%s(): Expecting a mode of 0755 on the first entry." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting a mode of 0755 (33261) on the first entry." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33261 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 2)
	   (setq unread-command-events (listify-key-sequence "0600\n"))
	   (cpio-dired-do-chmod 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting aaa, aaaa, aaaaa to have mode -rw------." test-name)
    (message "%s(): Expecting aaaaa.d to have mode dr--------." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rwxr-xr-x   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:A\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:A\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:A\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drw-------   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:A\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

  (message "%s(): Expecting an unchanged archive buffer." test-name)
  (message "%s(): The archive is not modified until saving." test-name)
  (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

  (message "%s(): Expecting aaa, aaaa, aaaaa to have mode 0100600 (33152)." test-name)
  (message "%s(): Expecting aaaaa.d to have mode 040600 (16768)." test-name)
  (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33261 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16768 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "0660\n"))
	   (cpio-dired-do-chmod)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting ... to have mode -rw-rw----." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rwxr-xr-x   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drw-------   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an untouched archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting ... to have mode 0100660 (33200)." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33261 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16768 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-save-archive)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting all the above mode changes in the archive buffer." test-name)
    (message "%s(): • a has mode 0100755 (100755)." test-name)
    (message "%s(): • aaa, aaaa, aaaaa have mode 0100600 (100600)." test-name)
    (message "%s(): • aaaaa.d has mode 040600 (040600)." test-name)
    (message "%s(): • ... have mode 0660 (100660 for files or 040660 for directories)." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100660	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100600	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100600	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040600	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100660	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100660	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting all the above mode changes in the dired buffer." test-name)
    (message "%s(): • a has mode -rwxr-xr-x" test-name)
    (message "%s(): • aaa, aaaa, aaaaa, aaaaa.d have mode -rw-r--r--" test-name)
    (message "%s(): • ... have mode -rw-rw----" test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rwxr-xr-x   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-------   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drw-------   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-rw----   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting all the above mode changes in the catalog." test-name)
    (message "%s(): • a has mode 33261." test-name)
    (message "%s(): • aaa, aaaa, aaaaa have mode 33152." test-name)
    (message "%s(): • aaaaa.d has mode 16768." test-name)
    (message "%s(): • ... have mode 33200 for files." test-name)
    (message "%s():                 16816 for directories." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33261 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33152 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16768 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33200 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-chown () ;✓
  "Test the function of M-x cpio-do-chown."
  (let ((test-name "cdmt-odc-cpio-dired-do-chown")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq unread-command-events (listify-key-sequence "9999\n"))
	   (cpio-dired-do-chown 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog))

    (message "%s(): The archive buffer is not modified until saved. (10741)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired buffer with the owner of 'a' being 9999." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  9999  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): The owner of 'a' should be 9999." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 9999 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))
    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (setq unread-command-events (listify-key-sequence "8888\n"))
	   (cpio-dired-do-chown 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The archive buffer is not modified until saved. (11111)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting 4 entries with owner 8888." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  8888  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  8888  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  8888  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  8888  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with 4 entries owned by 8888." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 335 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 8888 [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "7777\n"))
	   (cpio-dired-do-chown 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The archive buffer is not modified until saved. (10818)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting \`...\' to be owned by 7777." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  7777  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  7777  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  7777  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting ... to be owned by 7777." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-chown-1 ()
  "Test the change-owner-user function of M-x cpio-dired-do-chown."
  (let ((test-name "cdmt-odc-cpio-dired-do-chown-1")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq unread-command-events (listify-key-sequence "9999:1111\n"))
	   (cpio-dired-do-chown 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18063)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting entry 'a' to have owner 9999 and group 1111. (1605678037047079477)" test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  9999  1111        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting entry 'a' to have owner 9999 and group 1111. (1034533504227655228)" test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 9999 1111 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (setq unread-command-events (listify-key-sequence "8888:2222\n"))
	   (cpio-dired-do-chown 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched archive. (9918)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting 4 entries with owner 8888 and group 2222." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  8888  2222        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting 4 entries with owner 8888 and group 2222." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 2222 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 2222 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 335 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 8888 2222 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 8888 2222 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "7777:3333\n"))
	   (cpio-dired-do-chown 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched archive. (9958)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive*  cpio-archive-buffer-contents))

    (message "%s(): Expecting \`...\' to have owner 7777 and group 3333." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  7777  3333        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  7777  3333        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  7777  3333        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting ... to have owner 7777 and group 3333." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 3333 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 3333 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 7777 3333 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-compress ()
  "Test cpio-dired-do-compress.
cpio-dired-do-compress is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-compress)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-copy-0 () ;✓
  "Test the function of M-x cpio-do-copy."
  (let ((test-name "cdmt-odc-cpio-dired-do-copy-0")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq unread-command-events (listify-key-sequence "d\n"))
	   (cpio-dired-do-copy 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Checking that entry »a« has been copied to »d«." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
d	(( filename ))

a


" cpio-archive-buffer-contents))

    (message "%s(): Checking that there is an entry »d« in the dired style buffer." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting to see an entry »d«." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨d¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨d¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1621 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-copy-1 () ;✓
  "Test the function of M-x cpio-do-copy."
  ;; :expected-result :failed
  (let ((test-name "cdmt-odc-cpio-dired-do-copy-1")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (setq unread-command-events (listify-key-sequence "newDirectory\n"))
	   (cpio-dired-do-copy 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Checking for »aaa«, »aaaa«, »aaaaa«, »aaaaa« copied to newDirectory in the archive." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000025	(( namesize ))
000000	(( chksum   ))
newDirectory/aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory/aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000022	(( namesize ))
000000	(( chksum   ))
newDirectory/aaaa	(( filename ))

aaaa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000021	(( namesize ))
000000	(( chksum   ))
newDirectory/aaa	(( filename ))

aaa


" cpio-archive-buffer-contents))

    (message "%s(): Checking for the presence of »newDirectory/aaa«, »newDirectory/aaaa«, »newDirectory/aaaaa«, »newDirectory/aaaaa«." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
c drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa.d
c -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa
c -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaa
c -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaa
" cpio-dired-buffer-contents))

    (should (string-match "((¨a¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 64514 0 0 0 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 64514 0 0 0 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 64514 0 0 0 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 64514 0 0 0 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 64514 0 0 0 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa.d¨ .
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 64514 0 0 0 8 0 ¨aaaaa.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 64514 0 0 0 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 64514 0 0 0 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 64514 0 0 0 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 64514 0 0 0 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 64514 0 0 0 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb.d¨ .
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 64514 0 0 0 8 0 ¨bbbbb.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 64514 0 0 0 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 64514 0 0 0 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 64514 0 0 0 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 64514 0 0 0 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 64514 0 0 0 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc.d¨ .
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 64514 0 0 0 8 0 ¨ccccc.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa.d¨ .
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 64514 0 0 0 21 0 ¨newDirectory/aaaaa.d¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1640 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 64514 0 0 0 19 0 ¨newDirectory/aaaaa¨«
\\s-+#<marker at 1640 in alphabet_small.odc.cpio> #<marker at 1735 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 64514 0 0 0 18 0 ¨newDirectory/aaaa¨«
\\s-+#<marker at 1743 in alphabet_small.odc.cpio> #<marker at 1837 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaa¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 64514 0 0 0 17 0 ¨newDirectory/aaa¨«
\\s-+#<marker at 1845 in alphabet_small.odc.cpio> #<marker at 1938 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-copy-2 () ;✓
  "Test the function of M-x cpio-do-copy."
  (let ((test-name "cdmt-odc-cpio-dired-do-copy-2")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "newDirectory-1\n"))
	   (cpio-dired-do-copy 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))
    
    (message "%s(): Expecting an archive with each 3 letter entry copied to newDirectory-1." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-1/ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-1/bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-1/aaa	(( filename ))

aaa


" cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired bufffer with ... copied to newDirectory-1." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-1/ccc
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-1/bbb
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-1/aaa
" cpio-dired-buffer-contents))

    (message "%s(): Expecting to see ... entries in newDirectory-1." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-1/ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-1/ccc¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1638 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-1/bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-1/bbb¨«
\\s-+#<marker at 1644 in alphabet_small.odc.cpio> #<marker at 1739 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-1/aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-1/aaa¨«
\\s-+#<marker at 1745 in alphabet_small.odc.cpio> #<marker at 1840 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-copy-3 () ;✓
  "Test the function of M-x cpio-do-copy."
  (let ((test-name "cdmt-odc-cpio-dired-do-copy-3")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "...")
	   (setq unread-command-events (listify-key-sequence "newDirectory-3\n"))
	   (cpio-dired-do-copy 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an archive with each entry named with at least 3 letters copied to newDirectory-3." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000027	(( namesize ))
000000	(( chksum   ))
newDirectory-3/ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000025	(( namesize ))
000000	(( chksum   ))
newDirectory-3/ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000024	(( namesize ))
000000	(( chksum   ))
newDirectory-3/cccc	(( filename ))

cccc

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-3/ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000027	(( namesize ))
000000	(( chksum   ))
newDirectory-3/bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000025	(( namesize ))
000000	(( chksum   ))
newDirectory-3/bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000024	(( namesize ))
000000	(( chksum   ))
newDirectory-3/bbbb	(( filename ))

bbbb

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-3/bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000027	(( namesize ))
000000	(( chksum   ))
newDirectory-3/aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000025	(( namesize ))
000000	(( chksum   ))
newDirectory-3/aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000024	(( namesize ))
000000	(( chksum   ))
newDirectory-3/aaaa	(( filename ))

aaaa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000023	(( namesize ))
000000	(( chksum   ))
newDirectory-3/aaa	(( filename ))

aaa


" cpio-archive-buffer-contents))

    (message "%s(): Expecting all entries named with at least 3 letters to have copies in newDirectory-3." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
C drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/ccccc.d
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/ccccc
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/cccc
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/ccc
C drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/bbbbb.d
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/bbbbb
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/bbbb
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/bbb
C drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/aaaaa.d
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/aaaaa
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/aaaa
C -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-3/aaa
" cpio-dired-buffer-contents))

    (message "%s(): Expecting all entries named with at least 3 letters to have copies in newDirectory-3." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 23 0 ¨newDirectory-3/ccccc\.d¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1642 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 21 0 ¨newDirectory-3/ccccc¨«
\\s-+#<marker at 1642 in alphabet_small.odc.cpio> #<marker at 1739 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 20 0 ¨newDirectory-3/cccc¨«
\\s-+#<marker at 1747 in alphabet_small.odc.cpio> #<marker at 1843 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-3/ccc¨«
\\s-+#<marker at 1851 in alphabet_small.odc.cpio> #<marker at 1946 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 23 0 ¨newDirectory-3/bbbbb\.d¨«
\\s-+#<marker at 1952 in alphabet_small.odc.cpio> #<marker at 2051 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 21 0 ¨newDirectory-3/bbbbb¨«
\\s-+#<marker at 2051 in alphabet_small.odc.cpio> #<marker at 2148 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 20 0 ¨newDirectory-3/bbbb¨«
\\s-+#<marker at 2156 in alphabet_small.odc.cpio> #<marker at 2252 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-3/bbb¨«
\\s-+#<marker at 2260 in alphabet_small.odc.cpio> #<marker at 2355 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 23 0 ¨newDirectory-3/aaaaa\.d¨«
\\s-+#<marker at 2361 in alphabet_small.odc.cpio> #<marker at 2460 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 21 0 ¨newDirectory-3/aaaaa¨«
\\s-+#<marker at 2460 in alphabet_small.odc.cpio> #<marker at 2557 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 20 0 ¨newDirectory-3/aaaa¨«
\\s-+#<marker at 2565 in alphabet_small.odc.cpio> #<marker at 2661 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-3/aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-3/aaa¨«
\\s-+#<marker at 2669 in alphabet_small.odc.cpio> #<marker at 2764 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-copy-regexp ()
  "Test cpio-dired-do-copy-regexp.
cpio-dired-do-copy-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-copy-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-delete () ;✓
  "Test the function of M-x cpio-dired-do-delete."
  (let ((test-name "cdmt-odc-cpio-dired-do-delete")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-do-delete 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting entry »a« to be deleted." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting entry »a« to be deleted." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with entry »a« deleted." test-name)
    (should (string-match "((¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 80 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 85 in alphabet_small.odc.cpio> #<marker at 165 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 171 in alphabet_small.odc.cpio> #<marker at 252 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 259 in alphabet_small.odc.cpio> #<marker at 341 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 349 in alphabet_small.odc.cpio> #<marker at 433 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 433 in alphabet_small.odc.cpio> #<marker at 511 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 594 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 599 in alphabet_small.odc.cpio> #<marker at 679 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 685 in alphabet_small.odc.cpio> #<marker at 766 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 773 in alphabet_small.odc.cpio> #<marker at 855 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 863 in alphabet_small.odc.cpio> #<marker at 947 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 947 in alphabet_small.odc.cpio> #<marker at 1025 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1108 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1113 in alphabet_small.odc.cpio> #<marker at 1193 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1199 in alphabet_small.odc.cpio> #<marker at 1280 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1287 in alphabet_small.odc.cpio> #<marker at 1369 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1377 in alphabet_small.odc.cpio> #<marker at 1461 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (cpio-dired-do-delete 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired buffer with 4 entries deleted." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with entries" test-name)
    (message "%s():     »aaaa«, »aaaaa«, »aaaaa.d« and »b« deleted." test-name)
    (should (string-match "((¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 80 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 85 in alphabet_small.odc.cpio> #<marker at 165 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 171 in alphabet_small.odc.cpio> #<marker at 250 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 255 in alphabet_small.odc.cpio> #<marker at 335 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 422 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 429 in alphabet_small.odc.cpio> #<marker at 511 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 519 in alphabet_small.odc.cpio> #<marker at 603 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 603 in alphabet_small.odc.cpio> #<marker at 681 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 685 in alphabet_small.odc.cpio> #<marker at 764 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 769 in alphabet_small.odc.cpio> #<marker at 849 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 936 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 943 in alphabet_small.odc.cpio> #<marker at 1025 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1033 in alphabet_small.odc.cpio> #<marker at 1117 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "\n"))
	   (cpio-dired-do-delete 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
000000	(( mode     ))
000000	(( uid      ))
000000	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000013	(( namesize ))
000000	(( chksum   ))
TRAILER!!!	(( filename ))
\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired buffer with 4 entries deleted." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))
    (message "%s(): Expecting a catalog with further entries \`...\' deleted." test-name)
    (should (string-match "((¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 80 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 85 in alphabet_small.odc.cpio> #<marker at 164 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 169 in alphabet_small.odc.cpio> #<marker at 250 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 257 in alphabet_small.odc.cpio> #<marker at 339 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 347 in alphabet_small.odc.cpio> #<marker at 431 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 509 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 513 in alphabet_small.odc.cpio> #<marker at 592 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 678 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 685 in alphabet_small.odc.cpio> #<marker at 767 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 775 in alphabet_small.odc.cpio> #<marker at 859 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-flagged-delete ()
  "Test cpio-dired-do-flagged-delete.
cpio-dired-do-flagged-delete is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-flagged-delete)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-hardlink ()
  "Test cpio-dired-do-hardlink.
cpio-dired-do-hardlink is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-hardlink)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-hardlink-regexp ()
  "Test cpio-dired-do-hardlink-regexp.
cpio-dired-do-hardlink-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-hardlink-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-kill-lines ()
  "Test cpio-dired-do-kill-lines.
cpio-dired-do-kill-lines is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-kill-lines)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-print ()
  "Test cpio-dired-do-print.
cpio-dired-do-print is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-print)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-query-replace-regexp ()
  "Test cpio-dired-do-query-replace-regexp.
cpio-dired-do-query-replace-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-query-replace-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-redisplay ()
  "Test cpio-dired-do-redisplay.
cpio-dired-do-redisplay is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-redisplay)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-rename () ;✓
  (let ((test-name "cdmt-odc-cpio-dired-do-rename")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq unread-command-events (listify-key-sequence "d\n"))
	   (cpio-dired-do-rename 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched archive." test-name)
    (message "%s(): The archive gets updated on save." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a dired buffer with no entry »a«, but an entry »d«." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting catalog with first entry »d«." test-name)
    (should (string-match "((¨d¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨d¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 2)
	   (setq unread-command-events (listify-key-sequence "newDirectory\n"))
	   (cpio-dired-do-rename 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an as yet unchanged archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a dired style buffer with entries »aaaa«, »aaaaa«, »aaaaa.d« and »b« moved to »newDirectory«." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with the above changes." test-name)
    (should (string-match "((¨d¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨d¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 17 0 ¨newDirectory/aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 18 0 ¨newDirectory/aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory/aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 21 0 ¨newDirectory/aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq unread-command-events (listify-key-sequence "newDirectory-1\n"))
	   (cpio-dired-do-rename 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an as yet unchanged archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a dired buffer with \`...\' all under newDirectory-1." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory/aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-1/bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory-1/ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with \`...\' entries in newDirectory-1." test-name)
    (should (string-match "((¨d¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨d¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 17 0 ¨newDirectory/aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 18 0 ¨newDirectory/aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory/aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory/aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 21 0 ¨newDirectory/aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-1/bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-1/bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨newDirectory-1/ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 19 0 ¨newDirectory-1/ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-do-rename-regexp ()
  "Test cpio-dired-do-rename-regexp.
cpio-dired-do-rename-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-rename-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-search () ;HEREHERE ()
  "Test cpio-dired-do-search) ;HEREHERE.
cpio-dired-do-search) ;HEREHERE is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-search)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-symlink ()
  "Test cpio-dired-do-symlink.
cpio-dired-do-symlink is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-symlink)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-symlink-regexp ()
  "Test cpio-dired-do-symlink-regexp.
cpio-dired-do-symlink-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-symlink-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-do-touch ()
  "Test cpio-dired-do-touch.
cpio-dired-do-touch is not yet implemented -- expect an error."
  (should-error (cpio-dired-do-touch)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-downcase ()
  "Test cpio-dired-downcase.
cpio-dired-downcase is not yet implemented -- expect an error."
  (should-error (cpio-dired-downcase)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-extract-all ()
  "Test cpio-dired-extract-all.
cpio-dired-extract-all is not yet implemented -- expect an error."
  (should-error (cpio-dired-extract-all)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-extract-entries ()
  "Test cpio-dired-extract-entries.
cpio-dired-extract-entries is not yet implemented -- expect an error."
  (should-error (cpio-dired-extract-entries)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-find-alternate-entry ()
  "Test cpio-dired-find-alternate-entry.
cpio-dired-find-alternate-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-find-alternate-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-find-entry () ;✓
  "Test the function of M-x cpio-find-entry.
Expect errors about killed buffers.
They reflect an outstanding bug in cpio-affiliated buffers."

  (let ((test-name "cdmt-odc-cpio-dired-find-entry")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-contents-window)
	(entry-name)
	(past-entries ()))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq entry-name "aaa")
	   (cpio-dired-goto-entry entry-name)
	   (cpio-dired-display-entry)
	   ;; (cpio-dired-display-entry) changes the current buffer.
	   (with-current-buffer cpio-dired-buffer
	     (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name entry-name)))
	     (setq cpio-contents-buffer-string (with-current-buffer cpio-contents-buffer
						 (buffer-substring-no-properties (point-min) (point-max))))
	     (setq cpio-contents-window (get-buffer-window cpio-contents-buffer))
	     (setq cpio-archive-buffer-contents
		   (cdmt-odc-filter-archive-contents
		    (with-current-buffer cpio-archive-buffer
		      (buffer-substring-no-properties (point-min) (point-max)))))
	     (setq cpio-dired-buffer-contents
		   (with-current-buffer cpio-dired-buffer
		     (buffer-substring-no-properties (point-min) (point-max))))
	     (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog))))


    (with-current-buffer cpio-dired-buffer
      (message "%s(): Expect an untouched archive. (18064)" test-name)
      (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
      (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
      (should (not (null cpio-contents-buffer)))
      (should (buffer-live-p cpio-contents-buffer))
      (should (string-equal cpio-contents-buffer-string (concat "\n" entry-name "\n\n")))
      (should (window-live-p cpio-contents-window))
      (message "%s(): Expecting an unchanged catalog. (18038)" test-name)
      (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after)))

    (push entry-name past-entries)

    (switch-to-buffer cpio-dired-buffer)

    (progn (setq entry-name "ccc")
	   (cpio-dired-goto-entry entry-name)
	   (cpio-dired-display-entry)
	   ;; (cpio-dired-display-entry) changes the current-buffer.
	   (with-current-buffer cpio-dired-buffer
	     (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name entry-name)))
	     (setq cpio-contents-buffer-string (with-current-buffer cpio-contents-buffer
						 (buffer-substring-no-properties (point-min)
										 (point-max))))
	     (setq cpio-contents-window (get-buffer-window cpio-contents-buffer))
	     (setq cpio-archive-buffer-contents
		   (cdmt-odc-filter-archive-contents
		    (with-current-buffer cpio-archive-buffer
		      (buffer-substring-no-properties (point-min) (point-max)))))
	     (setq cpio-dired-buffer-contents
		   (with-current-buffer cpio-dired-buffer
		     (buffer-substring-no-properties (point-min) (point-max))))))

    (with-current-buffer cpio-dired-buffer
      (message "%s(): Expect an untouched archive. (18065)" test-name)
      (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
      (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
      (should (not (null cpio-contents-buffer)))
      (should (buffer-live-p cpio-contents-buffer))
      (should (string-equal cpio-contents-buffer-string "\nccc\n\n"))
      (should (window-live-p cpio-contents-window))
      (message "%s(): Expecting an unchanged catalog. (18039)" test-name)
      (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after)))

    ;; Now make sure that any past entries are still there.
    (mapc (lambda (en)
	    (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name entry-name)))
	    (setq cpio-contents-buffer-string (with-current-buffer cpio-contents-buffer
						(buffer-substring-no-properties (point-min)
										(point-max))))
	    (should (not (null cpio-contents-buffer)))
	    (should (buffer-live-p cpio-contents-buffer))
	    (should (string-equal cpio-contents-buffer-string (concat "\n" entry-name "\n\n")))
	    (should (window-live-p cpio-contents-window)))
	  past-entries)

    ;; Affiliated buffers don't get killed when the parent does yet.
    (push entry-name past-entries)
    (mapc (lambda (en)
	    (setq cpio-contents-buffer (get-buffer (cpio-contents-buffer-name en)))
	    (if (buffer-live-p cpio-contents-buffer)
		(kill-buffer cpio-contents-buffer)))
	  past-entries)))

(ert-deftest cdmt-odc-cpio-dired-find-entry-other-window ()
  "Test cpio-dired-find-entry-other-window.
cpio-dired-find-entry-other-window is not yet implemented -- expect an error."
  (should-error (cpio-dired-find-entry-other-window)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-flag-auto-save-entries () ;✓
  "Test the function of M-x cpio-dired-flag-auto-save-entries."
  (let ((test-name "cdmt-odc-cpio-dired-flag-auto-save-entries")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (beginning-of-line)
	   (while (re-search-forward " \\(.\\)$" (point-max) t)
	     (setq unread-command-events (listify-key-sequence (concat "#" (match-string-no-properties 1) "\n")))
	     (cpio-dired-do-copy 1))
	   (cpio-dired-flag-auto-save-entries)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an archive with autosave entries" test-name)
    (message "%s(): for each single character entry." test-name)
    (message "%s(): (The copy used to create them must update the archive.)" test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
#a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
#b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
#c	(( filename ))

c


" cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired-buffer with autosave files for single character entries." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} #a
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} #b
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} #c
" cpio-dired-buffer-contents))

    (message "%s(): Expecting to seee catalog entries for auto-save files for single character entries." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨#a¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨#a¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1622 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨#b¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨#b¨«
\\s-+#<marker at 1626 in alphabet_small.odc.cpio> #<marker at 1705 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨#c¨ .
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨#c¨«
\\s-+#<marker at 1709 in alphabet_small.odc.cpio> #<marker at 1788 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after)))))

(ert-deftest cdmt-odc-cpio-dired-flag-backup-entries ()
  "Test cpio-dired-flag-backup-entries.
cpio-dired-flag-backup-entries is not yet implemented -- expect an error."
  (should-error (cpio-dired-flag-backup-entries)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-flag-entries-regexp ()
  "Test cpio-dired-flag-entries-regexp.
cpio-dired-flag-entries-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-flag-entries-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-flag-entry-deletion () ;✓
  "Test the function of M-x cpio-flag-entry-deletion."
  (let ((test-name "cdmt-odc-cpio-dired-flag-entry-deletion")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-flag-entry-deletion 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18066)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired buffer with one entry flagged for deletion." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18040)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (cpio-dired-flag-entry-deletion 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18067)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a cpio-dired buffer with 4 more entries flagged for deletion." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
D drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18041)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-flag-garbage-entries ()
  "Test cpio-dired-flag-garbage-entries."
  (let ((test-name "cdmt-odc-cpio-dired-flag-entry-deletion")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(entry-name "aa"))

    (cdmt-reset 'make)

    (progn (setq cpio-dired-catalog-contents-before (cpio-catalog))
	   (cpio-dired-goto-entry entry-name)
	   (mapc (lambda (s)		;suffix
		   (setq unread-command-events (listify-key-sequence (concat entry-name "." s "\n")))
		   (cpio-dired-do-copy 1))
		 (list "aux" "bak" "dvi" "log" "orig" "rej" "toc"))
	   (cpio-dired-flag-garbage-entries)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an archive with entries for suffixes" test-name)
    (message "%s():     aux bak dvi log orig reg toc." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.aux	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.bak	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.dvi	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.log	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aa.orig	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.rej	(( filename ))

aa

\\0070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000007	(( namesize ))
000000	(( chksum   ))
aa.toc	(( filename ))

aa

\\0
" cpio-archive-buffer-contents))

    (message "%s(): Expecting a dired-style buffer with marked entries" test-name)
    (message "%s():     for the suffixes" test-name)
    (message "%s():     aux bak dvi log orig reg toc." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.aux
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.bak
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.dvi
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.log
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.orig
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.rej
D -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa.toc
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with entries with the suffixes" test-name)
    (message "%s():     aux bak dvi log orig reg toc." test-name)
    (should (string-match "((¨a¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\.d¨ \.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.aux¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.aux¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1626 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.bak¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.bak¨«
\\s-+#<marker at 1632 in alphabet_small.odc.cpio> #<marker at 1715 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.dvi¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.dvi¨«
\\s-+#<marker at 1721 in alphabet_small.odc.cpio> #<marker at 1804 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.log¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.log¨«
\\s-+#<marker at 1810 in alphabet_small.odc.cpio> #<marker at 1893 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.orig¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aa\.orig¨«
\\s-+#<marker at 1899 in alphabet_small.odc.cpio> #<marker at 1983 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.rej¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.rej¨«
\\s-+#<marker at 1989 in alphabet_small.odc.cpio> #<marker at 2072 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa\.toc¨ \.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 7 0 ¨aa\.toc¨«
\\s-+#<marker at 2078 in alphabet_small.odc.cpio> #<marker at 2161 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))

(ert-deftest cdmt-odc-cpio-dired-goto-entry ()
  "Test cpio-dired-goto-entry.
cpio-dired-goto-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-goto-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-hide-all ()
  "Test cpio-dired-hide-all.
cpio-dired-hide-all is not yet implemented -- expect an error."
  (should-error (cpio-dired-hide-all)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-hide-details-mode ()
  "Test cpio-dired-hide-details-mode) ;✓ Implemented by analogue to dired, but does nothing.
cpio-dired-hide-details-mode) ;✓ Implemented by analogue to dired, but does nothing is not yet implemented -- expect an error."
  (should-error (cpio-dired-hide-details-mode) ;✓ Implemented by analogue to dired, but does nothing)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-hide-subdir ()
  "Test cpio-dired-hide-subdir) ;.
cpio-dired-hide-subdir) ; is not yet implemented -- expect an error."
  (should-error (cpio-dired-hide-subdir)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mark () ;✓
  "Test the function of M-x cpio-dired-mark."
  (let ((test-name "cdmt-odc-cpio-dired-mark")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18068)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio-dired buffer with the first entry marked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18042)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 2)
	   (cpio-dired-mark 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal cpio-archive-buffer-contents *cdmt-odc-untouched-small-archive*))
    (message "%s(): Expecing a cpio-dired buffer with 4 more entries marked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18043)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-mark-directories ()
  "Test cpio-dired-mark-directories.
cpio-dired-mark-directories is not yet implemented -- expect an error."
  (should-error (cpio-dired-mark-directories)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mark-entries-containing-regexp ()
  "Test cpio-dired-mark-entries-containing-regexp.
cpio-dired-mark-entries-containing-regexp is not yet implemented -- expect an error."
  (should-error (cpio-dired-mark-entries-containing-regexp)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mark-entries-regexp () ;✓
  (let ((test-name "cdmt-odc-cpio-dired-mark-entries-regexp")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp "\\`...\\'")
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18069)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a cpio-dired buffer with ... marked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18044)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-mark-executables ()
  "Test cpio-dired-mark-executables.
cpio-dired-mark-executables is not yet implemented -- expect an error."
  (should-error (cpio-dired-mark-executables)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mark-subdir-entries ()
  "Test cpio-dired-mark-subdir-entries.
cpio-dired-mark-subdir-entries is not yet implemented -- expect an error."
  (should-error (cpio-dired-mark-subdir-entries)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mark-symlinks ()
  "Test cpio-dired-mark-symlinks.
cpio-dired-mark-symlinks is not yet implemented -- expect an error."
  (should-error (cpio-dired-mark-symlinks)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-mouse-find-entry-other-window ()
  "Test cpio-dired-mouse-find-entry-other-window.
cpio-dired-mouse-find-entry-other-window is not yet implemented -- expect an error."
  (should-error (cpio-dired-mouse-find-entry-other-window)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-next-dirline () ;✓
  "Test the function of M-x cpio-dired-next-dirline."
  (let ((test-name "cdmt-odc-cpio-dired-next-dirline")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(entry-name))

    (cdmt-reset 'make 'large)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 1)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should be aaaaa.d" test-name)
    (should (string-equal "aaaaa.d" entry-name))
    (message "%s(): Expecting an untouched large archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer should be untouched." test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 2)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should be ccccc.d" test-name)
    (should (string-equal "ccccc.d" entry-name))
    (message "%s(): The archive buffer should be untouched. (1)" test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer should be untouched. (1)" test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 4)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should be ggggg.d" test-name)
    (should (string-equal "ggggg.d" entry-name))
    (message "%s(): The archive buffer should be untouched. (2)" test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer shouold be untouched (2)" test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 8)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should be ooooo.d." test-name)
    (should (string-equal "ooooo.d" entry-name))
    (message "%s(): The archive buffer should be untouched. (3)" test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer should be untouched. (3)" test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 16)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should be zzzzz.d." test-name)
    (should (string-equal "zzzzz.d" entry-name))
    (message "%s(): The archive buffer should be untouched. (4)" test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer should be untouched. (4)" test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-dirline 1)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): The current entry should still be zzzzz.d." test-name)
    (should (string-equal "zzzzz.d" entry-name))
    (message "%s(): The archive buffer should be untouched. (5)" test-name)
    (should (string-equal *cdmt-odc-untouched-large-archive-buffer* cpio-archive-buffer-contents))
    (message "%s(): The dired style buffer should be untouched. (5)" test-name)
    (should (string-match *cdmt-odc-untouched-large-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog." test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-next-line () ;✓
  "Test the function of M-x cpio-dired-next-line."
  (let ((test-name "cdmt-odc-cpio-dired-next-line")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(entry-name))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal "a" entry-name))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expect an untouched archive. (18070)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18045)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 2)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal "aaa" entry-name))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expect an untouched archive. (18071)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 4)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (string-equal "b" entry-name))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expect an untouched archive. (18072)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18046)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 100)
	   (setq entry-name (cpio-dired-get-entry-name))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (equal nil entry-name))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expect an untouched archive. (18073)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18047)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-next-marked-entry ()
  "Test cpio-dired-next-marked-entry.
cpio-dired-next-marked-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-next-marked-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-next-marked-entry ()
  "Test cpio-dired-next-marked-entry.
cpio-dired-next-marked-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-next-marked-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-next-subdir ()
  "Test the function of M-x cpio-next-subdir."
  (should-error (cpio-dired-next-marked-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-prev-marked-entry ()
  "Test cpio-dired-prev-marked-entry.
cpio-dired-prev-marked-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-prev-marked-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-prev-marked-entry ()
  "Test cpio-dired-prev-marked-entry.
cpio-dired-prev-marked-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-prev-marked-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-prev-subdir ()
  "Test the function of M-x cpio-dired-prev-subdir."
  (should-error (cpio-dired-previous-line)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-previous-line () ;✓
  (let ((test-name "cdmt-odc-cpio-dired-previous-line")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(where))

    (cdmt-reset)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (goto-char (point-max))
	   (cpio-dired-previous-line 1)
	   (setq where (point))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (= where 1155))
    (should (string-match *cdmt-odc-small-archive* cpio-archive-buffer-contents))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18048)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-previous-line 2)
	   (setq where (point))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents 
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (= where 1019))
    (should (string-match *cdmt-odc-small-archive* cpio-archive-buffer-contents))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18049)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-previous-line 4)
	   (setq where (point))
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (should (= where 774))
    (message "%s(): Expecting and unchanged small archive. (16677)" test-name)
    (should (string-match *cdmt-odc-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting an untouched cpio-dired buffer. (16686)" test-name)
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18050)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-previous-line ()
  "Test cpio-dired-previous-line.
cpio-dired-previous-line is not yet implemented -- expect an error."
  (should-error (cpio-dired-previous-line)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-show-entry-type ()
  "Test cpio-dired-show-entry-type.
cpio-dired-show-entry-type is not yet implemented -- expect an error."
  (should-error (cpio-dired-show-entry-type)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-sort-toggle-or-edit ()
  "Test cpio-dired-sort-toggle-or-edit.
cpio-dired-sort-toggle-or-edit is not yet implemented -- expect an error."
  (should-error (cpio-dired-sort-toggle-or-edit)
		:type 'error))

;; I'm not sure how to test this.
;; (ert-deftest cdmt-odc-cpio-dired-summary () ;✓
;;   "Test the function of M-x cpio-dired-summary."
;;   (shell-command "cd test_data/alphabet ; make odc" nil nil)
;;   (let ((test-name "cdmt-odc-cpio-dired-summary")
;;         (cpio-archive-buffer (find-file-noselect  *cdmt-odc-small-archive*))
;;         (cpio-archive-buffer-contents)
;;         (cpio-dired-buffer)
;;         (cpio-dired-buffer-contents)
;;         )
;;     (with-current-buffer cpio-archive-buffer
;;       (cpio-mode))
;;     (setq cpio-dired-buffer (get-buffer-create (cpio-dired-buffer-name *cdmt-odc-small-archive*)))
;; 
;;     (should (string-equal (with-output-to-string
;; 			    (cpio-dired-summary))
;; 
;;     ))

(ert-deftest cdmt-odc-cpio-dired-toggle-marks ()
  "Test cpio-dired-toggle-marks.
cpio-dired-toggle-marks is not yet implemented -- expect an error."
  (should-error (cpio-dired-toggle-marks)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-toggle-marks ()
  "Test cpio-dired-toggle-marks.
cpio-dired-toggle-marks is not yet implemented -- expect an error."
  (should-error (cpio-dired-toggle-marks)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-toggle-read-only ()
  "Test cpio-dired-toggle-read-only.
cpio-dired-toggle-read-only is not yet implemented -- expect an error."
  (should-error (cpio-dired-toggle-read-only)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-undo ()
  "Test cpio-dired-undo.
cpio-dired-undo is not yet implemented -- expect an error."
  (should-error (cpio-dired-undo)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-unmark () ;✓
  "Test the function of M-x cpio-dired-unmark."
  (let ((test-name "cdmt-odc-cpio-dired-unmark")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp ".")
	   (cpio-dired-unmark 1)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched small archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with every entry except the first marked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18051)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-next-line 2)
	   (cpio-dired-unmark 2)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched small archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecing a dired bugger with all but two entries marked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18052)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 4)
	   (cpio-dired-unmark 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched small archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with another 4 entries unmarked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18053)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (dired-next-line 4)
	   (cpio-dired-unmark 4)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an untouched archive." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with yet the last entry unmarked." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18054)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-unmark-all-entries ()
  "Test cpio-dired-unmark-all-entries."
  (let ((test-name "cdmt-odc-cpio-dired-unmark")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp ".")
	   (cpio-dired-move-to-first-entry)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?A)
	   (cpio-dired-mark-this-entry ?B) (cpio-dired-mark-this-entry ?B)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E)
	   (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a variety of marks in a dired-style buffer." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
A -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
F drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18055)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-unmark-all-entries "" nil)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with no marks." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18056)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp ".")
	   (cpio-dired-move-to-first-entry)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?A)
	   (cpio-dired-mark-this-entry ?B) (cpio-dired-mark-this-entry ?B)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E)
	   (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a variety of marks in a dired-style buffer." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
A -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
F drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18057)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-unmark-all-entries "B" nil)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with no B marks." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
A -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
F drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18058)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-unmark-all-entries "F" nil)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with neither B nor F marks." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
A -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18059)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-unmark-all-marks ()
  "Test cpio-dired-unmark-all-marks."
  (let ((test-name "cdmt-odc-cpio-dired-unmark")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))
    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark-entries-regexp ".")
	   (cpio-dired-move-to-first-entry)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?A)
	   (cpio-dired-mark-this-entry ?B) (cpio-dired-mark-this-entry ?B)
	   (cpio-dired-next-line 2)
	   (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E) (cpio-dired-mark-this-entry ?E)
	   (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F) (cpio-dired-mark-this-entry ?F)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a variety of marks in a dired-style buffer." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
A -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:unmark]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
B -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
E -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
F drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
F -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
\\* -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
\\* drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18060)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-unmark-all-marks)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting an unchanged archive buffer." test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (message "%s(): Expecting a dired-style buffer with no marks." test-name)
    (should (string-match "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
" cpio-dired-buffer-contents))

    (message "%s(): Expecting an unchanged catalog. (18061)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-unmark-all-marks () ;✓
  "Test the function of M-x cpio-unmark-all-marks."
  (let ((test-name "cdmt-odc-cpio-dired-unmark-all-marks")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-mark 2)
	   (cpio-dired-next-line 2)
	   (let ((cpio-dired-marker-char cpio-dired-del-marker))
	     (cpio-dired-mark 4))
	   (let ((cpio-dired-marker-char cpio-dired-keep-marker-copy-str))
	     (cpio-dired-mark 8))
	   (let ((cpio-dired-marker-char cpio-dired-keep-marker-rename))
	     (cpio-dired-mark 16))
	   (cpio-dired-unmark-all-marks)
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expect an untouched archive. (18074)" test-name)
    (should (string-equal *cdmt-odc-untouched-small-archive* cpio-archive-buffer-contents))
    (should (string-match *cdmt-odc-untouched-small-dired-buffer* cpio-dired-buffer-contents))
    (message "%s(): Expecting an unchanged catalog. (18062)" test-name)
    (should (string-equal cpio-catalog-contents-before cpio-catalog-contents-after))))

(ert-deftest cdmt-odc-cpio-dired-unmark-backward ()
  "Test cpio-dired-unmark-backward.
cpio-dired-unmark-backward is not yet implemented -- expect an error."
  (should-error (cpio-dired-unmark-backward)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-up-directory ()
  "Test cpio-dired-up-directory.
cpio-dired-up-directory is not yet implemented -- expect an error."
  (should-error (cpio-dired-up-directory)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-upcase ()
  "Test cpio-dired-upcase.
cpio-dired-upcase is not yet implemented -- expect an error."
  (should-error (cpio-dired-upcase)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-view-archive () ;✓
  "Test the function of M-x cpio-view-archive."
  (let ((test-name "cdmt-odc-cpio-dired-view-archive")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(cpio-archive-window)
	(cpio-dired-window))

    (cdmt-reset 'make)

    (setq cpio-dired-window (get-buffer-window (get-buffer cpio-dired-buffer)))
    (should (window-live-p cpio-dired-window))
    (setq cpio-archive-window (get-buffer-window (get-buffer cpio-archive-buffer)))
    ;; (should (not (window-live-p cpio-dired-window)))
    (should (eq nil cpio-archive-window))

    (cpio-dired-view-archive)

    (setq cpio-dired-window (get-buffer-window (get-buffer cpio-dired-buffer)))
    ;; (should (not (window-live-p cpio-dired-window)))
    (should (eq nil cpio-dired-window))
    (setq cpio-archive-window (get-buffer-window (get-buffer cpio-archive-buffer)))
    (should (window-live-p cpio-archive-window))

    (cpio-view-dired-style-buffer)

    (setq cpio-dired-window (get-buffer-window (get-buffer cpio-dired-buffer)))
    (should (window-live-p cpio-dired-window))
    (setq cpio-archive-window (get-buffer-window (get-buffer cpio-archive-buffer)))
    ;; (should (not (window-live-p cpio-archive-window)))
    (should (eq nil cpio-archive-window))))

(ert-deftest cdmt-odc-cpio-dired-view-entry ()
  "Test cpio-dired-view-entry.
cpio-dired-view-entry is not yet implemented -- expect an error."
  (should-error (cpio-dired-view-entry)
		:type 'error))

(ert-deftest cdmt-odc-cpio-epa-dired-do-decrypt ()
  "Test cpio-epa-dired-do-decrypt.
cpio-epa-dired-do-decrypt is not yet implemented -- expect an error."
  (should-error (cpio-epa-dired-do-decrypt)
		:type 'error))

(ert-deftest cdmt-odc-cpio-epa-dired-do-encrypt ()
  "Test cpio-epa-dired-do-encrypt.
cpio-epa-dired-do-encrypt is not yet implemented -- expect an error."
  (should-error (cpio-epa-dired-do-encrypt)
		:type 'error))

(ert-deftest cdmt-odc-cpio-epa-dired-do-sign ()
  "Test cpio-epa-dired-do-sign.
cpio-epa-dired-do-sign is not yet implemented -- expect an error."
  (should-error (cpio-epa-dired-do-sign)
		:type 'error))

(ert-deftest cdmt-odc-cpio-epa-dired-do-verify ()
  "Test cpio-epa-dired-do-verify.
cpio-epa-dired-do-verify is not yet implemented -- expect an error."
  (should-error (cpio-epa-dired-do-verify)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-delete-tag ()
  "Test cpio-image-dired-delete-tag.
cpio-image-dired-delete-tag is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-delete-tag)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-dired-comment-entries ()
  "Test cpio-image-dired-dired-comment-entries.
cpio-image-dired-dired-comment-entries is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-dired-comment-entries)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-dired-display-external ()
  "Test cpio-image-dired-dired-display-external.
cpio-image-dired-dired-display-external is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-dired-display-external)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-dired-display-image ()
  "Test cpio-image-dired-dired-display-image.
cpio-image-dired-dired-display-image is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-dired-display-image)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-dired-edit-comment-and-tags ()
  "Test cpio-image-dired-dired-edit-comment-and-tags.
cpio-image-dired-dired-edit-comment-and-tags is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-dired-edit-comment-and-tags)
		:type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-dired-toggle-marked-thumbs ()
  "Test cpio-image-dired-dired-toggle-marked-thumbs.
cpio-image-dired-dired-toggle-marked-thumbs is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-dired-toggle-marked-thumbs)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-display-thumb ()
  "Test cpio-image-dired-display-thumb.
cpio-image-dired-display-thumb is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-display-thumb)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-display-thumbs ()
  "Test cpio-image-dired-display-thumbs.
cpio-image-dired-display-thumbs is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-display-thumbs)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-display-thumbs-append ()
  "Test cpio-image-dired-display-thumbs-append.
cpio-image-dired-display-thumbs-append is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-display-thumbs-append)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-jump-thumbnail-buffer ()
  "Test cpio-image-dired-jump-thumbnail-buffer.
cpio-image-dired-jump-thumbnail-buffer is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-jump-thumbnail-buffer)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-mark-tagged-entries ()
  "Test cpio-image-dired-mark-tagged-entries.
cpio-image-dired-mark-tagged-entries is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-mark-tagged-entries)
     :type 'error))

(ert-deftest cdmt-odc-cpio-image-dired-tag-entries ()
  "Test cpio-image-dired-tag-entries.
cpio-image-dired-tag-entries is not yet implemented -- expect an error."
  (should-error (cpio-image-dired-tag-entries)
     :type 'error))

;;;;;;;; (ert-deftest cdmt-odc-cpio-quit-window () ;✓
;;;;;;;;   "Test cpio-quit-window.
;;;;;;;; cpio-quit-window is not yet implemented -- expect an error."
;;;;;;;;   (let ((test-name "cdmt-odc-cpio-dired-quit-window")
;;;;;;;;         (cpio-archive-buffer)
;;;;;;;;         (cpio-archive-buffer-contents)
;;;;;;;;         (cpio-dired-buffer)
;;;;;;;;         (cpio-dired-buffer-contents)
;;;;;;;; 	(cpio-archive-window)
;;;;;;;; 	(cpio-dired-window)
;;;;;;;;         )
;;;;;;;;     (cdmt-reset 'make)

;;;;;;;;     (setq cpio-dired-window (get-buffer-window (get-buffer cpio-dired-buffer)))
;;;;;;;;     (should (window-live-p cpio-dired-window))
;;;;;;;;     (setq cpio-archive-window (get-buffer-window (get-buffer cpio-archive-buffer)))
;;;;;;;;     ;; (should (not (window-live-p cpio-dired-window)))
;;;;;;;;     (should (eq nil cpio-archive-window))

;;;;;;;; This causes an error under ERT.
;;;;;;;;     (cpio-quit-window)

;;;;;;;;     (setq cpio-dired-window (get-buffer-window (get-buffer cpio-dired-buffer)))
;;;;;;;;     (should (eq nil cpio-dired-window))
;;;;;;;;     (setq cpio-archive-window (get-buffer-window (get-buffer cpio-archive-buffer)))
;;;;;;;;     (should (eq nil cpio-archive-window))))

(ert-deftest cdmt-odc-revert-buffer ()
  "Test revert-buffer.
revert-buffer is not yet implemented -- expect an error."
  (should-error (revert-buffer)
		:type 'error))

(ert-deftest cdmt-odc-cpio-dired-create-directory ()
  "Test cpio-dired-create-directory."
  (let ((test-name "cdmt-odc-cpio-dired-create-directory")
        (cpio-archive-buffer)
        (cpio-archive-buffer-contents)
        (cpio-dired-buffer)
        (cpio-dired-buffer-contents)
	(cpio-catalog-contents-before)
	(cpio-catalog-contents-after)
	(cpio-archive-window)
	(cpio-dired-window))

    (cdmt-reset 'make)

    (progn (setq cpio-catalog-contents-before (cdmt-tidy-up-catalog))
	   (cpio-dired-create-directory "newDirectory")
	   (setq cpio-archive-buffer-contents
		 (cdmt-odc-filter-archive-contents
		  (with-current-buffer cpio-archive-buffer
		    (buffer-substring-no-properties (point-min) (point-max)))))
	   (setq cpio-dired-buffer-contents
		 (with-current-buffer cpio-dired-buffer
		   (buffer-substring-no-properties (point-min) (point-max))))
	   (setq cpio-catalog-contents-after (cdmt-tidy-up-catalog)))

    (message "%s(): Expecting a cpio archive with newDirectory, a new directory." test-name)
    (should (string-equal "070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
a	(( filename ))

a

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
aa	(( filename ))

aa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
aaa	(( filename ))

aaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
aaaa	(( filename ))

aaaa

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
aaaaa	(( filename ))

aaaaa

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
aaaaa.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
b	(( filename ))

b

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
bb	(( filename ))

bb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
bbb	(( filename ))

bbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
bbbb	(( filename ))

bbbb

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
bbbbb	(( filename ))

bbbbb

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
bbbbb.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000004	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000002	(( namesize ))
000000	(( chksum   ))
c	(( filename ))

c

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000005	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000003	(( namesize ))
000000	(( chksum   ))
cc	(( filename ))

cc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000006	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000004	(( namesize ))
000000	(( chksum   ))
ccc	(( filename ))

ccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000007	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000005	(( namesize ))
000000	(( chksum   ))
cccc	(( filename ))

cccc

070707	(( magic    ))
DEADBE	(( ino      ))
100644	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000010	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000006	(( namesize ))
000000	(( chksum   ))
ccccc	(( filename ))

ccccc

070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000002	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000010	(( namesize ))
000000	(( chksum   ))
ccccc.d	(( filename ))
070707	(( magic    ))
DEADBE	(( ino      ))
040755	(( mode     ))
001750	(( uid      ))
001750	(( gid      ))
000001	(( nlink    ))
DEADBE	(( mtime    ))
00000000000	(( filesize ))
DEADBE	(( dev maj  ))
DEADBE	(( dev min  ))
DEADBE	(( rdev maj ))
DEADBE	(( rdev min ))
000015	(( namesize ))
000000	(( chksum   ))
newDirectory	(( filename ))

" cpio-archive-buffer-contents))

    (message "%s(): Expecting a cpio dired buffer with newDirectory, a new directory." test-name)
    (should (string-match  "CPIO archive: alphabet_small.odc.cpio:

  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} a
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaa
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} aaaaa.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} b
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbb
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} bbbbb.d
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        4 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} c
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        5 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        6 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        7 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} cccc
  -rw-r--r--   1  [[:digit:]]+  [[:digit:]]+        8 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc
  drwxr-xr-x   2  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} ccccc.d
  drwxr-xr-x   1  [[:digit:]]+  [[:digit:]]+        0 \\(?:a\\(?:pr\\|ug\\)\\|dec\\|feb\\|j\\(?:an\\|u[ln]\\)\\|ma[ry]\\|nov\\|oct\\|sep\\) [[:digit:]]\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\} newDirectory
" cpio-dired-buffer-contents))

    (message "%s(): Expecting a catalog with a new directory called »newDirectory«." test-name)
    (should (string-match "((¨newDirectory¨ \\.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 13 0 ¨newDirectory¨«
\\s-+#<marker at 1543 in alphabet_small.odc.cpio> #<marker at 1632 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨a¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨a¨«
\\s-+#<marker at 1 in alphabet_small.odc.cpio> #<marker at 79 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aa¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨aa¨«
\\s-+#<marker at 83 in alphabet_small.odc.cpio> #<marker at 162 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaa¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨aaa¨«
\\s-+#<marker at 167 in alphabet_small.odc.cpio> #<marker at 247 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaa¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨aaaa¨«
\\s-+#<marker at 253 in alphabet_small.odc.cpio> #<marker at 334 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨aaaaa¨«
\\s-+#<marker at 341 in alphabet_small.odc.cpio> #<marker at 423 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨aaaaa\\.d¨ \\.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨aaaaa\\.d¨«
\\s-+#<marker at 431 in alphabet_small.odc.cpio> #<marker at 515 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨b¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨b¨«
\\s-+#<marker at 515 in alphabet_small.odc.cpio> #<marker at 593 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bb¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨bb¨«
\\s-+#<marker at 597 in alphabet_small.odc.cpio> #<marker at 676 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbb¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨bbb¨«
\\s-+#<marker at 681 in alphabet_small.odc.cpio> #<marker at 761 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbb¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨bbbb¨«
\\s-+#<marker at 767 in alphabet_small.odc.cpio> #<marker at 848 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨bbbbb¨«
\\s-+#<marker at 855 in alphabet_small.odc.cpio> #<marker at 937 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨bbbbb\\.d¨ \\.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨bbbbb\\.d¨«
\\s-+#<marker at 945 in alphabet_small.odc.cpio> #<marker at 1029 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨c¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+4 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 2 0 ¨c¨«
\\s-+#<marker at 1029 in alphabet_small.odc.cpio> #<marker at 1107 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cc¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+5 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 3 0 ¨cc¨«
\\s-+#<marker at 1111 in alphabet_small.odc.cpio> #<marker at 1190 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccc¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+6 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 4 0 ¨ccc¨«
\\s-+#<marker at 1195 in alphabet_small.odc.cpio> #<marker at 1275 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨cccc¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+7 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 5 0 ¨cccc¨«
\\s-+#<marker at 1281 in alphabet_small.odc.cpio> #<marker at 1362 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc¨ \\.
\\s-+»»[[:digit:]]+ 33188 [[:digit:]]+ [[:digit:]]+ 1
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+8 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 6 0 ¨ccccc¨«
\\s-+#<marker at 1369 in alphabet_small.odc.cpio> #<marker at 1451 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«)
\\s-+(¨ccccc\\.d¨ \\.
\\s-+»»[[:digit:]]+ 16877 [[:digit:]]+ [[:digit:]]+ 2
\\s-+([[:digit:]]+ [[:digit:]]+)
\\s-+0 [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ [[:digit:]]+ 8 0 ¨ccccc\\.d¨«
\\s-+#<marker at 1459 in alphabet_small.odc.cpio> #<marker at 1543 in alphabet_small.odc.cpio> cpio-mode-entry-unmodified«))
" cpio-catalog-contents-after))

    (cdmt-test-save *cdmt-archive-format*)))


;;
;; Run tests
;;

(unless noninteractive 
  (setq debug-on-error t)
  (ert "^cdmt-odc-"))

(cdmt-reset)

;;; cpio-dired-test.el ends here.
