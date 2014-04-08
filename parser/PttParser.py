from BaseHTMLProcessor import BaseHTMLProcessor
import re
from itertools import count

class PttBoardParser(BaseHTMLProcessor):

    def board(self,boardname, start=1, end=None, verbose=False):
        import urllib

        for idx in count(start):
            if end and idx>end:
                break
            url = "http://www.ptt.cc/bbs/%(boardname)s/index%(idx)d.html" % locals()
            usock = urllib.urlopen( url )
            if verbose:
                print url
            self.pieces = []
            self.feed(usock.read())
            if len(self.pieces) == 0:
                break

    def reset(self):

        self._start_a = None
        self.methodQueue = []
        self.divClassStack = []
        self.articleRec = []
        BaseHTMLProcessor.reset(self)

    def start_div(self, attrs):
        div_class = dict(attrs).get( "class" ) or "None"
        self.divClassStack.append( div_class )

        # method call for start tag
        start_method = getattr( self, "_div_%s_start" % re.sub('[ -]+','_',div_class), None )
        if start_method:
            start_method(attrs)

        # method to handle nested tags
        method = getattr( self, "_div_%s" % re.sub('[ -]+','_',div_class), None )
        self.methodQueue.append(method)

    def end_div(self):
        div_class = self.divClassStack.pop()
        method = self.methodQueue.pop()
        end_method = getattr(self, "_div_%s_end" % re.sub('[ -]+','_',div_class), None )
        if end_method:
            end_method()

    def start_a(self,attrs):
        if self._start_a:
            self._start_a(attrs)
        else:
            BaseHTMLProcessor.unknown_starttag(self,"a",attrs)

    def end_a(self):
        if self._start_a:
            method = getattr( self, self._start_a.__name__.replace('start','end'), None )
            if method:
                method()
        else:
            BaseHTMLProcessor.unknown_endtag(self,"a")

    def handle_data(self,text):
        method = self.methodQueue[-1] if len(self.methodQueue) else None
        if method:
            method(text)

    def _div_r_ent_start(self,attrs):
        self.tempArticleRec = {k:None for k in ('push','title','url')}

    def _div_r_ent_end(self):
        self.articleRec.append(self.tempArticleRec)

    def _div_nrec(self,text):
        try:
            push_count = int(text)
            self.tempArticleRec['push'] = push_count
        except:
            self.tempArticleRec['push'] = text

    def _div_title_start(self,text):
        self._start_a = self._div_title_a_start

    def _div_title_end(self):
        self._star_a = None

    def _div_title_a(self,text):
        self.tempArticleRec['title'] = text

    def _div_title_a_start(self,attrs):
        self.tempArticleRec['url'] = dict(attrs).get('href')
        self.methodQueue.append(self._div_title_a)

    def _div_title_a_end(self):
        self.methodQueue.pop()


class PttArticleParser(BaseHTMLProcessor):
    def reset(self):
        self.meta = {'data':''}
        self.div_stack = [] # keep track of div
        self.methodStack = []
        BaseHTMLProcessor.reset(self)

    def parse_article(self,url):
        from urllib import urlopen
        usock = urlopen(url)
        self.feed(usock.read())
        self.close()
        usock.close()

    def start_div(self, attrs):
        """append div id to the stack"""
        div_id = dict(attrs).get( 'id' )
        self.div_stack.append( div_id )

        method = getattr( self, "_div_%s_start" % str( div_id ).replace('-','_'), None )
        if method:
            method(attrs)

        method = getattr( self, "_div_%s" % str( div_id ).replace('-','_'), None )
        self.methodStack.append(method)

        self.unknown_starttag("div", attrs)

    def end_div(self):
        self.div_stack.pop()
        method = self.methodStack.pop()
        self.unknown_endtag("div")

    def start_span(self, attrs):
        """get corresponding span method"""
        span_class = dict(attrs).get( 'class' ) or "None"
        method = getattr( self, "_span_%s" % span_class.replace('-','_'), None )
        self.methodStack.append(method)

    def end_span(self):
        method = self.methodStack.pop()
        #end_method = getattr( self, "%s_end" % method.__name__, None )

    def handle_data(self, text):
        if len(self.methodStack):
            method = self.methodStack[-1]
            if method:
                method(text)

    def _div_main_content(self,text):
        self.meta['data'] += text

    #def _div_main_content_start(self,attrs):
    #    self.main_content_flag = None

    #def _div_main_content_end(self):
    #    del self.main_content_flag

    def _span_article_meta_tag(self, text):
        self.tmp_article_meta_tag = text

    def _span_article_meta_value(self, text):
        self.meta[self.tmp_article_meta_tag] = text

if __name__ == "__main__":
    import urllib
    usock = urllib.urlopen("http://www.ptt.cc/bbs/FuMouDiscuss/M.1396739358.A.B39.html")
    a = PttArticleParser()
    a.feed( usock.read() )
    a.close()
    for key,val in a.meta.items():
        print "%s: %s" % (key,val)
#    print a.data
#    usock.close()
#    usock = urllib.urlopen("http://www.ptt.cc/bbs/FuMouDiscuss/index1252.html")
#    a = PttBoardParser()
#    a.feed( usock.read() )
#    a.close()
#    for art in a.articleRec:
#        for k,v in art.items():
#            print str(k) + ':' + str(v)

#    b = PttBoardParser(verbose=True)
#    b.board("FuMouDiscuss")

