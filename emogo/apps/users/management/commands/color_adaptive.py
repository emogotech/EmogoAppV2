import struct
import numpy as np
import scipy
import urllib2

import cStringIO

from PIL import Image
from django.core.management.base import BaseCommand

from emogo.apps.stream.models import *

class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def add_color(self, image):
        import scipy.misc
        import scipy.cluster
        NUM_CLUSTERS = 5

        file = cStringIO.StringIO(urllib2.urlopen(image).read())
        im = Image.open(file)
        im = im.resize((150, 150))      # optional, to reduce time
        ar = np.asarray(im)
        shape = ar.shape
        ar = ar.reshape(scipy.product(shape[:2]), shape[2]).astype(float)
        codes, dist = scipy.cluster.vq.kmeans(ar, NUM_CLUSTERS)
        vecs, dist = scipy.cluster.vq.vq(ar, codes)         # assign codes
        counts, bins = scipy.histogram(vecs, len(codes))    # count occurrences

        index_max = scipy.argmax(counts)                    # find most frequent
        peak = codes[index_max]
        colour = ''.join(chr(int(c)) for c in peak).encode('hex')
        print 'most frequent color is  #%s \n' % ( colour)
        return colour

    def handle(self, *args, **options):
        # Get all Streams data
        streams = Stream.objects.all().order_by('id')
        print 'total stream count %s', streams.count()
        print '\n'

        count = 0
        print 'Start stream count %s', count
        print '\n'

        for stream in streams:
            if stream.color == None:

                print 'stream count is %s ', count
                print '\n'
                print 'reading stream image %s %s ', stream.id, stream.image
                print '\n'
                try:
                    colour = self.add_color(stream.image)
                    stream.color = '#%s' % colour
                    stream.save()
                except Exception as e:
                    print 'getting stream error %s and image is %s \n', stream.id, stream.image
                    pass
            count = count + 1

        # # Get all contents data
        contents = Content.objects.all().order_by('id')
        print 'total content count %s', contents.count()

        content_count = 0
        print 'Start content count %s', content_count

        for content in contents:
            if content.color == None :

                print 'content count is %s ', content_count
                print 'reading content image %s %s ', content.id, content.video_image
                try:
                    colour = self.add_color(content.video_image)
                    content.color = '#%s' % colour
                    content.save()
                except Exception as e:
                    print 'getting content error %s and image is %s \n', content.id, content.video_image
                    pass
            content_count = content_count + 1
