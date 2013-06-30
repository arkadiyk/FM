window.FotomooFixtures ||= {}
window.FotomooFixtures.folders =
  page0:
    nextPageToken: "nextPageToken1"
    items: [
      {id: "folder1",     title: "Folder One",           parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder2",     title: "Folder Two",           parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder3-2-1", title: "Folder Three Two One", parents: [{id: "folder3-2", isRoot: false}]}
      {id: "folder3",     title: "Folder Three",         parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder4",     title: "Folder Four",          parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder5-1",   title: "Folder Five One",      parents: [{id: "folder5",   isRoot: false}]}
    ]
  nextPageToken1:
    items: [
      {id: "folder5",     title: "Folder Five",          parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder3-1",   title: "Folder Three One",     parents: [{id: "folder3",   isRoot: false}]}
      {id: "folder3-2",   title: "Folder Three Two",     parents: [{id: "folder3",   isRoot: false}]}

      {id: "folder-fm",   title: "Fotomoo Pictures",     parents: [{id: "folder0",   isRoot: true}]}

      {id: "folder-2001",   title: "Folder 2001",        parents: [{id: "folder-fm",   isRoot: false}]}
      {id: "folder-2007",   title: "Folder 2007",        parents: [{id: "folder-fm",   isRoot: false}]}
      {id: "folder-2001-01",   title: "Folder 2001-01",       parents: [{id: "folder-2001",   isRoot: false}]}
      {id: "folder-2001-04",   title: "Folder 2001-04",       parents: [{id: "folder-2001",   isRoot: false}]}
      {id: "folder-2007-02",   title: "Folder 2007-02",       parents: [{id: "folder-2007",   isRoot: false}]}
      {id: "folder-2007-03",   title: "Folder 2007-03",       parents: [{id: "folder-2007",   isRoot: false}]}
      {id: "folder-2007-06",   title: "Folder 2007-06",       parents: [{id: "folder-2007",   isRoot: false}]}
      {id: "folder7",     title: "Folder Seven",         parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder3-2-2", title: "Folder Three Two Two", parents: [{id: "folder3-2", isRoot: false}]}
    ]
