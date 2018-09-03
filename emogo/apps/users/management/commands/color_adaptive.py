import struct
import numpy as np
import scipy
import urllib, cStringIO

from PIL import Image
from django.core.management.base import BaseCommand

from emogo.apps.stream.models import *

class Command(BaseCommand):
    help = 'Closes the specified poll for voting'
    def handle(self, *args, **options):
        # Get all Streams data
        streams = Stream.objects.all().order_by('id')
        print 'total count %s \n', streams.count()
        count = 0
        print 'Start count %s \n', count
        for stream in streams:
            if stream.color == None:
                import scipy.misc
                import scipy.cluster
                NUM_CLUSTERS = 5
                print 'count is %s \n', count
                print 'reading image %s %s \n', stream.id, stream.image
                try:
                    file = cStringIO.StringIO(urllib.urlopen(stream.image).read())
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
                    stream.color = '#%s' % colour
                    stream.save()
                    print 'most frequent color is  #%s \n' % ( colour)
                except Exception as e:
                    print 'getting error %s and image is %s \n', stream.id, stream.image
                    pass
            count = count + 1
