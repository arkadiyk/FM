FM.File = Ember.Object.extend
  isFile: true
  selected: false

  address: (->
    return null unless @get("imageMediaMetadata.location.latitude")
    FM.Address.find(@get("imageMediaMetadata.location.latitude"), @get("imageMediaMetadata.location.longitude"))
  ).property()

  year: (->
    @get('exifDate')?.split(':')[0] || "unknown"
  ).property('exifDate')

  month: (->
    @get('exifDate')?.split(':')[1] || "unknown"
  ).property('exifDate')

  exifDate: (->
    @get('imageMediaMetadata.date')?.split(' ')[0]
  ).property('imageMediaMetadata.date')

FM.File.reopenClass
  find: (fid) -> FM.drive.findImageFile(fid)
