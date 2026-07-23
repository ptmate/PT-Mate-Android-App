import re
import os

files = [
    '/Users/admin/aryan/projects/client/PT/lib/calendar/image.dart',
    '/Users/admin/aryan/projects/client/PT-business/lib/calendar/image.dart'
]

old_get_image = '''  getImage() async {
    if(widget.item.image == "") {
      setState(() {
        img = 'https://www.ptmate.app/img/no-image.png';
      });
    } else if(widget.item.image.indexOf('adm-') != -1) {
      setState(() {
        img = 'https://www.ptmate.app/img/exercises/'+widget.item.image+'.jpg';
      });
    } else {
      final ref = FirebaseStorage.instance.ref().child('/images/exercises/'+widget.item.image);
      var url = await ref.getDownloadURL();
      setState(() {
        img = url;
      });
    }
  }'''

new_get_image = '''  getImage() async {
    if(widget.item.image == "") {
      if (mounted) {
        setState(() {
          img = 'https://www.ptmate.app/img/no-image.png';
        });
      }
    } else if(widget.item.image.startsWith('http')) {
      if (mounted) {
        setState(() {
          img = widget.item.image;
        });
      }
    } else if(widget.item.image.indexOf('adm-') != -1) {
      if (mounted) {
        setState(() {
          img = 'https://www.ptmate.app/img/exercises/'+widget.item.image+'.jpg';
        });
      }
    } else {
      final ref = FirebaseStorage.instance.ref().child('/images/exercises/'+widget.item.image);
      var url = await ref.getDownloadURL();
      if (mounted) {
        setState(() {
          img = url;
        });
      }
    }
  }'''

for filepath in files:
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()

        content = content.replace(old_get_image, new_get_image)

        with open(filepath, 'w') as f:
            f.write(content)

