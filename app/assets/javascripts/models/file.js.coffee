FM.File = Ember.Object.extend
  isFile: true
  selected: false

  parentObj: (->
    @get('parents').map (parent_ref) ->
      id = if parent_ref.isRoot then 'root' else parent_ref.id
      FM.Folder.find(id)
  ).property('parents','parents.@each')

  isFotomoo: (->
    @get('parentObj').someProperty('isFotomoo', true)
  ).property('parentObj','parentObj.@each.isFotomoo')

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
