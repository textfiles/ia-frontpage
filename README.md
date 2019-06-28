# FRONTPAGE.SH

In which a minor annoyance in the Internet Archive ecosystem is repaired in the most non-intuitive way possible.

WHAT THIS SCRIPT TRIES TO SOLVE

In the early years of the Internet Archive book scanning project, an issue that quickly arose with the uploading of scanned books was the actual "cover" of the books would be blank or without information. The reason for this was the focus on hardcover (or vintage) books, where the cover itself would be made of cloth and contain all the information inside.

When scanning in a book, the workers involved would mark off an internal page as the "cover leaf", the page with the most actual information of use to a viewer, and this designated page (which might be the second or even the tenth page in) would be what was shown first in the reader. Over time, as the archive switched to a thumbnail default mode, this coverleaf would be what was shown as the "icon" for the book.

However, in the expanse of time, and with the opening up of the archive's "stacks" to non-institutions and individuals, very little of the contributed text-based items use anything other than the first page as the "cover", yet the system will continue to try and find an internal page that "looks" like a cover and make that the default. 

The solution is to make the default for open uploads into the first page as cover, and the system only used for internal work. But that solution is not here. Therefore, we have FRONTPAGE, a bash script that uses the ia client to make the cover page change.

This script requires the Internet Archive Client to be in its path. You can get this client here:
https://archive.org/services/docs/api/internetarchive/

To invoke the script, use:

./frontpage.sh [items]

[items] can be a single identifier on the Internet Archive (including a URL), or a collection name, or a local file with a list of identifiers.

The script will do its best with what you give it. Bear in mind that post-modification, it may take a few minutes before the cover switch is reflected in the archive's pages when you view them - pressing SHIFT and reloading your browser may help as well.

Created by Jason Scott, Free-Range Archivist at the Internet Archive.
