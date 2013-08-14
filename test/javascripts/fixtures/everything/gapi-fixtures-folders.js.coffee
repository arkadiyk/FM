window.FotomooFixtures01 ||= {}
window.FotomooFixtures01.folders =
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

      {id: "folder-fm-by-date",   title: "By Date",     parents: [{id: "folder-fm",   isRoot: false}]}

      {id: "folder-2002",   title: "2002",        parents: [{id: "folder-fm-by-date",   isRoot: false}]}
      {id: "folder-2012",   title: "2012",        parents: [{id: "folder-fm-by-date",   isRoot: false}]}
      {id: "folder-2002-01",   title: "01",       parents: [{id: "folder-2002",   isRoot: false}]}
      {id: "folder-2002-05",   title: "05",       parents: [{id: "folder-2002",   isRoot: false}]}
      {id: "folder-2012-02",   title: "02",       parents: [{id: "folder-2012",   isRoot: false}]}
      {id: "folder-2012-03",   title: "03",       parents: [{id: "folder-2012",   isRoot: false}]}
      {id: "folder-2012-06",   title: "06",       parents: [{id: "folder-2012",   isRoot: false}]}
      {id: "folder7",     title: "Folder Seven",         parents: [{id: "folder0",   isRoot: true}]}
      {id: "folder3-2-2", title: "Folder Three Two Two", parents: [{id: "folder3-2", isRoot: false}]}
    ]
