(define (crop-ppm filename)
  (let* 
    (
    (image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
    (drawable (car (gimp-image-get-active-layer image)))
    )

  ; crop the image
  (plug-in-zealouscrop RUN-NONINTERACTIVE image drawable)

  ; save in original png format
  (file-png-save RUN-NONINTERACTIVE image drawable filename filename
       0 6 0 0 0 1 1)

  ; clean up the image
  (gimp-image-delete image)
  )
)
