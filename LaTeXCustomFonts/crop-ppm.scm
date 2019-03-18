;; A Scheme plugin for GIMP
(define (crop-ppm input-filename output-filename)
  (let* 
    (
    (image (car (gimp-file-load RUN-NONINTERACTIVE input-filename input-filename)))
    (drawable (car (gimp-image-get-active-layer image)))
    )

  ; crop the image
  (plug-in-zealouscrop RUN-NONINTERACTIVE image drawable)

  (gimp-image-delete-layer RUN-NONINTERACTIVE image 4)

  ; save in original png format
  (file-ppm-save RUN-NONINTERACTIVE image drawable output-filename output-filename 1)

  ; clean up the image
  (gimp-image-delete image)
  )
)
