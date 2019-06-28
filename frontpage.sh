#!/bin/sh

# FRONTPAGE.SH
# By Jason Scott, jscott@archive.org
# Free-Range Archivist, Internet Archive (archive.org)

# Problem: Due to historical scanning of books with no unique or discernible
# cover, Internet Archive by default sets all text-based uploads to the 
# "title leaf", an item which doesn't exist for anyone who is not scanning
# books. It will often then choose a random page within the text item.
# This script forces the declaration to be the first page, always.
# It can do individual items, a collection, or use a list in a textfile.

# The script sets the LEAF in the .xml of the item to page 0. 

# If there is a filename with the first argument, it will use that file
# for the item list, instead of generating one from the collection. If
# the first argument is a collection or item, it will use that.

# If you don't have access to the item, it'll just fail a lot.

# MAIN PROGRAM

# Did you even give us an argument; you're killing me Smalls

if [ ! "$1" ]
   then
   echo "No collection name, item or existing item list given. Please give a collection name or filename."
   exit 1
fi

# Now let's see if this system has the Internet Archive Client installed.

VERSION=`ia --version`

if [ ! "$VERSION" ]
   then
   echo "It does not appear the ia client is in your path. You need to install it."
   echo "Visit https://archive.org/services/docs/api/internetarchive/cli.html for information."
   exit 1
fi

# Special Use Case: You can feed this script a pile of arguments and it's like running it
# over and over. It'll give you a LOT of output (for now, unless we do major surgery)
# but it will do the right thing. Otherwise, use as the docs say.

for BOOKYWOOK in $@
    do

# Now, about that argument.
# Is it a filename or a collection, and finally.. an item?
if [ -f "$BOOKYWOOK" ]
   then
   echo "Working with a file: $BOOKYWOOK"
   FILE=1
   else
   MET=`ia metadata "$BOOKYWOOK" | grep '"mediatype": "collection",'`
   if [ "$MET" ]
      then
      COLLECTION=1
      echo "Working with a collection: $BOOKYWOOK"
      else
      ITEM=`echo $BOOKYWOOK | sed 's/.*\///g'`
      ITEM=`ia metadata "$ITEM" | grep '"mediatype": "texts",'`
      if [ "$ITEM" ]
         then
         ITEM=1
         echo "Working with a single item: $BOOKYWOOK"
         else
         echo "The argument is not a collection, a file, or an item. Exiting."
         exit 1
      fi
   fi
fi

# Now you have a file that uses the argument and makes a sorted *.txt file of items.
# Bring the noise - go through all the items in the list.

if [ "$COLLECTION" ]
   then
   LISTING=`ia search collection:$BOOKYWOOK --itemlist | sort -u`
   else 
   if [ "$ITEM" ]
      then
      LISTING="$BOOKYWOOK"
      else
      LISTING=`cat $BOOKYWOOK | sort -u`
   fi 
fi

echo "==============================="
echo "Total items being worked with: `echo $LISTING | wc -w`"
echo "==============================="

COUNT=0

# Go make a subdirectory to do all this work, because sometimes the client
# or the Internet Archive system just blows up and it leaves subdirectories everywhere.

REPOSITORY="$$"

mkdir "FRONTPAGE.$REPOSITORY" 

if [ -d "FRONTPAGE.$REPOSITORY" ]
   then
   cd FRONTPAGE.$REPOSITORY
   else
   echo "Something is wrong - can't make a working directory here."
   echo "Please move to a directory with write privileges."
   exit 1
fi

for book in `echo $LISTING`
do
    echo "========== $book ========="

# If "coverleaf" is set, don't waste time, we're good.

COVER=`ia metadata $book | grep '"coverleaf"'`
 
if [ "$COVER" ]
   then
   echo "Cover already set. Skipping."
  
  else
    
    SCAND=`ia list ${book} | grep _scandata.xml | head -1`
         if [ "$SCAND" ]
            then
            ia download "${book}" "$SCAND"
            echo "$SCAND downloaded."
            mv "${book}/$SCAND" .
   
            if [ -s "$SCAND" ]
               then

            # Here we go.... find it, number it.

            MATCHLINE=`cat "$SCAND" | grep -n "<pageType>Title<\/pageType>" | cut -f1 -d':'`
            LESSONE=$((${MATCHLINE} - 1))
            if [ "$LESSONE" -eq "-1" ]
               then
               echo "No title page set!"
               LESSONE=0
            fi
            PAGENUM=`cat "$SCAND" | head -${LESSONE} | tail -1`
            if [ "${PAGENUM}" = '    <page leafNum="0">' ]
               then
                  echo "NO CHANGE NEEDED."
               else
                  # Clean out the Title Pagetype.
                  cat "$SCAND" | sed 's/<pageType>Title</<pageType>Normal</g' > ${1}.cleaned.txt
                  # Let's play swapping the first page.
                  MATCHLINE=`cat ${1}.cleaned.txt | grep -n '<page leafNum="0">' | cut -f1 -d':'`
                  head -${MATCHLINE} ${1}.cleaned.txt > "$SCAND"
                  echo "      <pageType>Title</pageType>" >> "$SCAND"
                  PLUSONE=$((${MATCHLINE} + 2))
                  tail -n +${PLUSONE} ${1}.cleaned.txt >> "$SCAND"
                  ia upload -n "$book" "$SCAND" # Set No-Derive, since it's just fine.
                  ia metadata "$book" -m "coverleaf:0"
                  rm -f "$SCAND" ${1}.cleaned.txt
                  COUNT=$(($COUNT + 1))
             fi
             else
             echo "Whoops, .xml is zero."
            fi
             rmdir "${book}"
             rm -f "$SCAND"
         else
             echo "No scandata.xml for $book."
       fi
    fi
    done

echo "Total items updated: $COUNT out of `echo $LISTING | wc -w`"

cd ..
rm -rf "FRONTPAGE.$REPOSITORY"

done
