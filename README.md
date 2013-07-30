# Fotomoo

**A tool to manage large photo libraries stored on the cloud**

The project's goal is to make management of digital assets on the cloud as effortless as possible.

At this moment it works with Google drive only

POC: http://fotomoo.com

### The code

It looks like a Rails project but it is not. At this moment it is purely CoffeScript / Ember.js application, 
which uses Google Drive as a backend. I am using rails to compile assets only. There is a 
chance that one day the project will have a server part to
do image processing. I am still not sure which server-side framework that would be. Rails or Node, most likely.

## Current State.

At this moment the application can organise photos on Google Drive by automatically creating 
multiple hierarchies and assigning searchable indexes to your photos based on image EXIF date and geotags.

To give it a test drive you can export a large amount of scaled down photos to your google drive 
and then try to organize them by navigating on to "Organize!" page of fotomoo.com.


## Coming soon

__Shared Library__ to organize and manage a single Fotomoo library from multiple accounts.

__Mobile App__ to search and browse photo library in the cloud. Will let you instantly find a
picture you are looking for and show it on your mobile device. The picture will be scaled to an
optimal resolution to minimize the loading time and network bandwidth.

__Manage Page__. In the coming weeks you will be able to Manage your photo library on the cloud using Fotomoo:

  * __Search__, __Filter__, __Select__ and __Share__ Fotomoo
managed pictures using all automatically and manually created attributes. In fact
this is what Fotomoo is created for =)
  * __Edit__ your photos by integrating with Google Drive 3rd party tools like Picmonkey or Pics.io
  * __Fine tune__ the structure and searchable indexes which Fotomoo has automatically created for you.
  * Create your __own hierarchies__ and searchable indexes
  * __Rate__ and __Flag__ your photos, assign __Description__

For now you can take advantage of automatically created hierarchies and indexes using Google Drive web UI

## The future

Fotomoo will use __image processing__ to organize and help to enhance images in much greater way.
