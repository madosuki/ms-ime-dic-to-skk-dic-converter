(ql:quickload :cl-ppcre)
(ql:quickload :babel)

(defun split-from-tab (s)
  (let ((tmp (ppcre:split "\\t" s)))
    (if tmp
        tmp
        (list s))))

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

(defun main ()
  (let ((tmp (remove-comment-line (split-from-line-code (open-dic-txt "/home/kouf/Downloads/ime_dic/nicoime_msime.txt")))))
    (print (length tmp))
    (print (car tmp))
    (print (car (mapcar #'split-from-tab tmp)))))
