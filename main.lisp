(ql:quickload :cl-ppcre)
(ql:quickload :babel)

(defconstant declare-utf-8-message ";; -*- mode: fundamental; coding: utf-8 -*-" "declare of skk dictionary encoding is utf-8.")
(defconstant declare-okuri-ari-line ";; okuri-ari entries."
  "Declare that attribute of comment specify, that attribute spread below lines of that comment. If next comment appear, become end of that effect.")
(defconstant declare-okuri-nasi-line ";; okuri-nasi entries."
  "Declare that attribute of comment specify, that attribute spread below lines of that comment. If next comment appear, become end of that effect.")

(defun split-from-tab (s)
  (let ((tmp (ppcre:split "\\t" s)))
    (if tmp
        (format nil "~A /~A/" (car tmp) (cadr tmp))
        "")))

(defun split-from-line-code (s)
  (cl-ppcre:split #\linefeed s))

(defun remove-comment-line (l)
  (delete-if (lambda (x) (if (cl-ppcre:scan "^![\\w\\W\\s:]+$" x) t
                             (if (equal x "")
                                 t
                                 nil)))
             l))

(defun open-dic-txt (name &optional (external-format :SJIS) (error-count 0))
  (let ((text nil))
    (with-open-file (input name
                           :direction :input
                           :if-does-not-exist nil
                           :element-type '(unsigned-byte 8))
      (let ((buf (make-array (file-length input) :element-type '(unsigned-byte 8))))
        (read-sequence buf input)
        (setq text (handler-case (babel:octets-to-string buf :encoding external-format)
                     (error (e)
                       (case error-count
                         (0 (open-dic-txt name :UTF-16 (1+ error-count)))
                         (1 (open-dic-txt name :UTF-8 (1+ error-count)))
                         (otherwise
                          (format t "Error!: ~A~%" e)
                          (return-from open-dic-txt 'error))))))
        (cl-ppcre:regex-replace-all #\return text "")))))

(defun write-to-text-file (name l)
  (with-open-file (out name
                       :direction :output
                       :if-exists :supersede)
    (write-line declare-utf-8-message out)
    (write-line declare-okuri-ari-line out)
    (write-line declare-okuri-nasi-line out)
    (dolist (x l)
      (write-line x out))))

(defun main ()
  (let ((tmp (remove-comment-line (split-from-line-code (open-dic-txt "/home/kouf/Downloads/nicoime/nicoime_msime.txt")))))
    (format t "~A~%" (length tmp))
    (let ((result (mapcar #'split-from-tab tmp)))
      (write-to-text-file "./test.dic" result))))
