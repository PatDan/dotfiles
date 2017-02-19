"pythoncomplete.vim - Omni Completion for python
" Maintainer: Aaron Griffin <aaronmgriffin@gmail.com>
" Version: 0.9
" Last Updated: 18 Jun 2009
"
" Changes
" TODO:
" 'info' item output can use some formatting work
" Add an "unsafe eval" mode, to allow for return type evaluation
" Complete basic syntax along with import statements
"   i.e. "import url<c-x,c-o>"
" Continue parsing on invalid line??
"
" v 0.9
"   * Fixed docstring parsing for classes and functions
"   * Fixed parsing of *args and **kwargs type arguments
"   * Better function param parsing to handle things like tuples and
"     lambda defaults args
"
" v 0.8
"   * Fixed an issue where the FIRST assignment was always used instead of
"   using a subsequent assignment for a variable
"   * Fixed a scoping issue when working inside a parameterless function
"
"
" v 0.7
"   * Fixed function list sorting (_ and __ at the bottom)
"   * Removed newline removal from docs.  It appears vim handles these better in
"   recent patches
"
" v 0.6:
"   * Fixed argument completion
"   * Removed the 'kind' completions, as they are better indicated
"   with real syntax
"   * Added tuple assignment parsing (whoops, that was forgotten)
"   * Fixed import handling when flattening scope
"
" v 0.5:
" Yeah, I skipped a version number - 0.4 was never public.
"  It was a bugfix version on top of 0.3.  This is a complete
"  rewrite.
"
"This is a Hack setting will only work if you have textwidth=80
"eg in your .vimrc. So far I cant get omnifunc to return multiline completions
"
"set textwidth=80
"let g:pythoncomplete_include_super = 1
"
" It will include a formatted super() statement on completing a subclass
" method.
"
"
if !exists('g:pythoncomplete_include_super')
    let g:pythoncomplete_include_super = 0
endif

if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! pythoncomplete#Complete(findstart, base)
    "findstart = 1 when we need to get the text length
    if a:findstart == 1
        let line = getline('.')
        let idx = col('.')
        while idx > 0
            let idx -= 1
            let c = line[idx]
            if c =~ '\w'
                continue
            elseif ! c =~ '\.'
                let idx = -1
                break
            else
                break
            endif
        endwhile

        return idx
    "findstart = 0 when we need to return the list of completions
    else
        "vim no longer moves the cursor upon completion... fix that
        let line = getline('.')
        let idx = col('.')
        let cword = ''
        while idx > 0
            let idx -= 1
            let c = line[idx]
            if c =~ '\w' || c =~ '\.'
                let cword = c . cword
                continue
            elseif strlen(cword) > 0 || idx == 0
                break
            endif
        endwhile
        execute "python vimcomplete('" . cword . "', '" . a:base . "')"
        return g:pythoncomplete_completions
    endif
endfunction

function! s:DefPython()
python << PYTHONEOF
import sys, tokenize, cStringIO, types, re
from token import NAME, DEDENT, NEWLINE, STRING
import vim

debugstmts=[]
def dbg(s): debugstmts.append(s)
def showdbg():
    for d in debugstmts: print "DBG: %s " % d

def complsort(x,y):
    try:
        xa = x['abbr']
        ya = y['abbr']
        if xa[0] == '_':
            if xa[1] == '_' and ya[0:2] == '__':
                return xa > ya
            elif ya[0:2] == '__':
                return -1
            elif y[0] == '_':
                return xa > ya
            else:
                return 1
        elif ya[0] == '_':
            return -1
        else:
           return xa > ya
    except:
        return 0

def vimcomplete(context,match):
    global debugstmts
    debugstmts = []
    try:
        cmpl = Completer()
        cmpl.evalsource('\n'.join(vim.current.buffer),vim.eval("line('.')"))

        all = cmpl.get_completions(context,match)

        icmpl = ImportCompleter()
        iall = icmpl.get_completions(vim.current.line)
        if len(iall) > 0:
            all = iall
        else:
            scmpl = SuperCompleter()
            sall = scmpl.get_completions(vim.current.line)
            if len(sall) > 0:
                all = sall

        all.sort(complsort)

        dictstr = '['
        # have to do this for double quoting
        for cmpl in all:
            dictstr += '{'
            for x in cmpl: dictstr += '"%s":"%s",' % (x,cmpl[x])
            dictstr += '"icase":0},'
        if dictstr[-1] == ',': dictstr = dictstr[:-1]
        dictstr += ']'
        #dbg("dict: %s" % dictstr)
        vim.command("silent let g:pythoncomplete_completions = %s" % dictstr)
        #dbg("Completion dict:\n%s" % all)
    except vim.error:
        dbg("VIM Error: %s" % vim.error)

class Completer(object):
    def __init__(self):
       self.compldict = {}
       self.parser = PyParser()

    def evalsource(self,text,line=0):
        sc = self.parser.parse(text,line)
        src = sc.get_code()
        dbg("source: %s" % src)
        try: exec(src) in self.compldict
        except: dbg("parser: %s, %s" % (sys.exc_info()[0],sys.exc_info()[1]))
        for l in sc.locals:
            try: exec(l) in self.compldict
            except: dbg("locals: %s, %s [%s]" % (sys.exc_info()[0],sys.exc_info()[1],l))

    def _cleanstr(self,doc):
        return doc.replace('"',' ').replace("'",' ')

    def get_arguments(self,func_obj):
        def _ctor(obj):
            try: return class_ob.__init__.im_func
            except AttributeError:
                for base in class_ob.__bases__:
                    rc = _find_constructor(base)
                    if rc is not None: return rc
            return None

        arg_offset = 1
        if type(func_obj) == types.ClassType: func_obj = _ctor(func_obj)
        elif type(func_obj) == types.MethodType: func_obj = func_obj.im_func
        else: arg_offset = 0

        arg_text=''
        if type(func_obj) in [types.FunctionType, types.LambdaType]:
            try:
                cd = func_obj.func_code
                real_args = cd.co_varnames[arg_offset:cd.co_argcount]
                defaults = func_obj.func_defaults or ''
                defaults = map(lambda name: "=%s" % name, defaults)
                defaults = [""] * (len(real_args)-len(defaults)) + defaults
                items = map(lambda a,d: a+d, real_args, defaults)
                if func_obj.func_code.co_flags & 0x4:
                    items.append("...")
                if func_obj.func_code.co_flags & 0x8:
                    items.append("***")
                arg_text = (','.join(items)) + ')'

            except:
                dbg("arg completion: %s: %s" % (sys.exc_info()[0],sys.exc_info()[1]))
                pass
        if len(arg_text) == 0:
            # The doc string sometimes contains the function signature
            #  this works for alot of C modules that are part of the
            #  standard library
            doc = func_obj.__doc__
            if doc:
                doc = doc.lstrip()
                pos = doc.find('\n')
                if pos > 0:
                    sigline = doc[:pos]
                    lidx = sigline.find('(')
                    ridx = sigline.find(')')
                    if lidx > 0 and ridx > 0:
                        arg_text = sigline[lidx+1:ridx] + ')'
        if len(arg_text) == 0: arg_text = ')'
        return arg_text

    def get_completions(self,context,match):
        dbg("get_completions('%s','%s')" % (context,match))
        stmt = ''
        if context: stmt += str(context)
        if match: stmt += str(match)
        try:
            result = None
            all = {}
            ridx = stmt.rfind('.')
            if len(stmt) > 0 and stmt[-1] == '(':
                result = eval(_sanitize(stmt[:-1]), self.compldict)
                doc = result.__doc__
                if doc is None: doc = ''
                args = self.get_arguments(result)
                return [{'word':self._cleanstr(args),'info':self._cleanstr(doc)}]
            elif ridx == -1:
                match = stmt
                all = self.compldict
            else:
                match = stmt[ridx+1:]
                stmt = _sanitize(stmt[:ridx])
                result = eval(stmt, self.compldict)
                all = dir(result)

            dbg("completing: stmt:%s" % stmt)
            completions = []

            try: maindoc = result.__doc__
            except: maindoc = ' '
            if maindoc is None: maindoc = ' '
            for m in all:
                if m == "_PyCmplNoType": continue #this is internal
                try:
                    dbg('possible completion: %s' % m)
                    if m.find(match) == 0:
                        if result is None: inst = all[m]
                        else: inst = getattr(result,m)
                        try: doc = inst.__doc__
                        except: doc = maindoc
                        typestr = str(inst)
                        if doc is None or doc == '': doc = maindoc

                        wrd = m[len(match):]
                        c = {'word':wrd, 'abbr':m,  'info':self._cleanstr(doc)}
                        if "function" in typestr:
                            c['word'] += '('
                            c['abbr'] += '(' + self._cleanstr(self.get_arguments(inst))
                        elif "method" in typestr:
                            c['word'] += '('
                            c['abbr'] += '(' + self._cleanstr(self.get_arguments(inst))
                        elif "module" in typestr:
                            c['word'] += '.'
                        elif "class" in typestr:
                            c['word'] += '('
                            c['abbr'] += '('
                        completions.append(c)
                except:
                    i = sys.exc_info()
                    dbg("inner completion: %s,%s [stmt='%s']" % (i[0],i[1],stmt))
            return completions
        except:
            i = sys.exc_info()
            dbg("completion: %s,%s [stmt='%s']" % (i[0],i[1],stmt))
            return []


class CompletionModule(object):
    def doc(self,str):
        """ Clean up a docstring TODO: Duplicated. This could be global """
        d = str.replace('\n',' ')
        d = d.replace('\t',' ')
        d = d.replace('"','\\"')
        while d.find('  ') > -1: d = d.replace('  ',' ')
        while d[0] in '"\'\t ': d = d[1:]
        while d[-1] in '"\'\t ': d = d[:-1]
        dbg("docstr = %s" % (d))

        return d
class ImportCompleter(CompletionModule):
    """
    for importing top level modules and
    from <module> import <attr> statements
    """

    def get_completions(self,text,line=0):
        """
            Look for lines containing import or from foo import
        """
        dbg('ImportCompleter.get_completions(%s)' % text)
        match = re.compile(r'^\s*(from|import)\s+(\w*)$').match(text)
        if match:
            matches = []
            dbg('possible root module complete')
            subword = match.groups()[1].strip()
            self.mods = [m for m in sys.modules.keys() \
                if m.find(subword) == 0]
            #This is just to clear submodules as there are too many results
            if not '.' in subword:
                self.mods = [m for m in self.mods if '.' not in m]

            dbg('mods %s' % self.mods)
            for mod in self.mods:
                mod_doc = sys.modules[mod].__doc__ or ''
                if not mod_doc == '':
                    mod_doc = self.doc(mod_doc)

                dbg(mod_doc)

                matches.append({
                    'word':mod[len(subword):],
                    'info':mod_doc,
                    'abbr':mod
                })

            dbg("Top Level Import %s" % matches)
            return matches

        match = re.compile(r'^\s*from\s+([\w\.]+)\s+import\s+(.*)$').match(text)

        if match:
            dbg("from match __import__('%s') " % match.groups()[0] )
            try:
                self.mod = import_and_get_mod(match.groups()[0])
            except:
                dbg("Failed import_and_get_mod")
                return []

            ims = [m.strip() for m in match.groups()[1].split(',')]
            lead = ims.pop()

            matches = []

            self.atts = [a for a in dir(self.mod) \
                if a.find(lead) == 0 and a not in ims]

            for att in self.atts:
                try:
                    att_doc = getattr(self.mod,att).__doc__ or ''
                except:
                    att_doc = ''

                if not att_doc == '':
                    try:
                        att_doc = self.doc(att_doc)
                    except:
                        att_doc = ''

                matches.append({
                    'word':att[len(lead):],
                    'info':att_doc,
                    'abbr':att
                }
                )

            return matches

        return []

class SuperCompleter(CompletionModule):
    """
         This is for autocompleting a superclasses methods.

        Eg:

        class Bar(object):
            def wibble()

        class Foo(Bar):

            def wib<c-x><c-o> should get wibble
    """

    def get_completions(self,text):

        include_super = vim.eval('g:pythoncomplete_include_super')

        match = re.compile(r'\s+def (\w*)$').match(text)
        if match:
            class_line = vim.eval('getline(search("^\s*class " , "bn",0))')
            class_list = re.compile('\s+|\(|\)').split(class_line.strip())

            dbg("class_list: %s" % class_list)

            if not class_list or not len(class_list)==4:
                return []

            klass, superclasses = class_list[1:3]

            #TODO add option for mixins
            superclass = superclasses.split(',')[0].strip()

            dbg('SuperCompleter: %s' % class_line)

            #piggybacking here on the original completion module
            cmpl = Completer()
            cmpl.evalsource('\n'.join(vim.current.buffer),vim.eval("line('.')"))
            context = ''
            leader = match.groups()[0]
            all = cmpl.get_completions(context,"%s.%s" % (superclass,leader))

            for m in all:
                #TODO This is assuming self... need cls
                dbg("ATTR: %s" % m['abbr'])
                try:
                    #TODO this is ugly
                    word_list = re.compile(r'\(|\)').split(m['abbr'])
                    func = word_list[0]
                    word_list[0] = word_list[0][len(leader) :] #get rid of leading text
                    args = word_list[1]
                    word_list[1] = "(%s)" % ",".join(['self']+ [
                        w for w in word_list[1].split(',') if not w == ''])
                    dbg("word_list %s" % word_list)
                    m['word'] = "".join(word_list) + ":"

                    if include_super:
                        #TODO Padding hack. I cant seem to get newlines
                        m['word'] += "                                                                   return super(%s,self).%s(%s)" % (
                            klass,
                            func,
                            re.compile("=[^,]+(,|$)").sub('\\1',args)
                        )

                    #replace omnicompletes abbrev syntax
                    m['word'] = m['word'].replace(
                        '...', '*args').replace(
                        '***', '**kwargs')
                except:
                    #This fails when it is not a function
                    #I might reintroduce it
                    dbg('Deleting: %s' % m['word'])
                    del m


                #TODO: This is crude. Should be looking for type(o).__name__ = 'instancemethod'
                all = [a for a in all if '(' in a['abbr']]

            all.sort(complsort)
            return all

        return []

class Scope(object):
    def __init__(self,name,indent,docstr=''):
        self.subscopes = []
        self.docstr = docstr
        self.locals = []
        self.parent = None
        self.name = name
        self.indent = indent

    def add(self,sub):
        #print 'push scope: [%s@%s]' % (sub.name,sub.indent)
        sub.parent = self
        self.subscopes.append(sub)
        return sub

    def doc(self,str):
        """ Clean up a docstring """
        d = str.replace('\n',' ')
        d = d.replace('\t',' ')
        while d.find('  ') > -1: d = d.replace('  ',' ')
        while d[0] in '"\'\t ': d = d[1:]
        while d[-1] in '"\'\t ': d = d[:-1]
        dbg("Scope(%s)::docstr = %s" % (self,d))
        self.docstr = d

    def local(self,loc):
        self._checkexisting(loc)
        self.locals.append(loc)

    def copy_decl(self,indent=0):
        """ Copy a scope's declaration only, at the specified indent level - not local variables """
        return Scope(self.name,indent,self.docstr)

    def _checkexisting(self,test):
        "Convienance function... keep out duplicates"
        if test.find('=') > -1:
            var = test.split('=')[0].strip()
            for l in self.locals:
                if l.find('=') > -1 and var == l.split('=')[0].strip():
                    self.locals.remove(l)

    def get_code(self):
        str = ""
        if len(self.docstr) > 0: str += '"""'+self.docstr+'"""\n'
        for l in self.locals:
            if l.startswith('import'): str += l+'\n'
        str += 'class _PyCmplNoType:\n    def __getattr__(self,name):\n        return None\n'
        for sub in self.subscopes:
            str += sub.get_code()
        for l in self.locals:
            if not l.startswith('import'): str += l+'\n'

        return str

    def pop(self,indent):
        #print 'pop scope: [%s] to [%s]' % (self.indent,indent)
        outer = self
        while outer.parent != None and outer.indent >= indent:
            outer = outer.parent
        return outer

    def currentindent(self):
        #print 'parse current indent: %s' % self.indent
        return '    '*self.indent

    def childindent(self):
        #print 'parse child indent: [%s]' % (self.indent+1)
        return '    '*(self.indent+1)

class Class(Scope):
    def __init__(self, name, supers, indent, docstr=''):
        Scope.__init__(self,name,indent, docstr)
        self.supers = supers
    def copy_decl(self,indent=0):
        c = Class(self.name,self.supers,indent, self.docstr)
        for s in self.subscopes:
            c.add(s.copy_decl(indent+1))
        return c
    def get_code(self):
        str = '%sclass %s' % (self.currentindent(),self.name)
        if len(self.supers) > 0: str += '(%s)' % ','.join(self.supers)
        str += ':\n'
        if len(self.docstr) > 0: str += self.childindent()+'"""'+self.docstr+'"""\n'
        if len(self.subscopes) > 0:
            for s in self.subscopes: str += s.get_code()
        else:
            str += '%spass\n' % self.childindent()
        return str


class Function(Scope):
    def __init__(self, name, params, indent, docstr=''):
        Scope.__init__(self,name,indent, docstr)
        self.params = params
    def copy_decl(self,indent=0):
        return Function(self.name,self.params,indent, self.docstr)
    def get_code(self):
        str = "%sdef %s(%s):\n" % \
            (self.currentindent(),self.name,','.join(self.params))
        if len(self.docstr) > 0: str += self.childindent()+'"""'+self.docstr+'"""\n'
        str += "%spass\n" % self.childindent()
        return str

class PyParser:
    def __init__(self):
        self.top = Scope('global',0)
        self.scope = self.top

    def _parsedotname(self,pre=None):
        #returns (dottedname, nexttoken)
        name = []
        if pre is None:
            tokentype, token, indent = self.next()
            if tokentype != NAME and token != '*':
                return ('', token)
        else: token = pre
        name.append(token)
        while True:
            tokentype, token, indent = self.next()
            if token != '.': break
            tokentype, token, indent = self.next()
            if tokentype != NAME: break
            name.append(token)
        return (".".join(name), token)

    def _parseimportlist(self):
        imports = []
        while True:
            name, token = self._parsedotname()
            if not name: break
            name2 = ''
            if token == 'as': name2, token = self._parsedotname()
            imports.append((name, name2))
            while token != "," and "\n" not in token:
                tokentype, token, indent = self.next()
            if token != ",": break
        return imports

    def _parenparse(self):
        name = ''
        names = []
        level = 1
        while True:
            tokentype, token, indent = self.next()
            if token in (')', ',') and level == 1:
                if '=' not in name: name = name.replace(' ', '')
                names.append(name.strip())
                name = ''
            if token == '(':
                level += 1
                name += "("
            elif token == ')':
                level -= 1
                if level == 0: break
                else: name += ")"
            elif token == ',' and level == 1:
                pass
            else:
                name += "%s " % str(token)
        return names

    def _parsefunction(self,indent):
        self.scope=self.scope.pop(indent)
        tokentype, fname, ind = self.next()
        if tokentype != NAME: return None

        tokentype, open, ind = self.next()
        if open != '(': return None
        params=self._parenparse()

        tokentype, colon, ind = self.next()
        if colon != ':': return None

        return Function(fname,params,indent)

    def _parseclass(self,indent):
        self.scope=self.scope.pop(indent)
        tokentype, cname, ind = self.next()
        if tokentype != NAME: return None

        super = []
        tokentype, next, ind = self.next()
        if next == '(':
            super=self._parenparse()
        elif next != ':': return None

        return Class(cname,super,indent)

    def _parseassignment(self):
        assign=''
        tokentype, token, indent = self.next()
        if tokentype == tokenize.STRING or token == 'str':
            return '""'
        elif token == '(' or token == 'tuple':
            return '()'
        elif token == '[' or token == 'list':
            return '[]'
        elif token == '{' or token == 'dict':
            return '{}'
        elif tokentype == tokenize.NUMBER:
            return '0'
        elif token == 'open' or token == 'file':
            return 'file'
        elif token == 'None':
            return '_PyCmplNoType()'
        elif token == 'type':
            return 'type(_PyCmplNoType)' #only for method resolution
        else:
            assign += token
            level = 0
            while True:
                tokentype, token, indent = self.next()
                if token in ('(','{','['):
                    level += 1
                elif token in (']','}',')'):
                    level -= 1
                    if level == 0: break
                elif level == 0:
                    if token in (';','\n'): break
                    assign += token
        return "%s" % assign

    def next(self):
        type, token, (lineno, indent), end, self.parserline = self.gen.next()
        if lineno == self.curline:
            #print 'line found [%s] scope=%s' % (line.replace('\n',''),self.scope.name)
            self.currentscope = self.scope
        return (type, token, indent)

    def _adjustvisibility(self):
        newscope = Scope('result',0)
        scp = self.currentscope
        while scp != None:
            if type(scp) == Function:
                slice = 0
                #Handle 'self' params
                if scp.parent != None and type(scp.parent) == Class:
                    slice = 1
                    newscope.local('%s = %s' % (scp.params[0],scp.parent.name))
                for p in scp.params[slice:]:
                    i = p.find('=')
                    if len(p) == 0: continue
                    pvar = ''
                    ptype = ''
                    if i == -1:
                        pvar = p
                        ptype = '_PyCmplNoType()'
                    else:
                        pvar = p[:i]
                        ptype = _sanitize(p[i+1:])
                    if pvar.startswith('**'):
                        pvar = pvar[2:]
                        ptype = '{}'
                    elif pvar.startswith('*'):
                        pvar = pvar[1:]
                        ptype = '[]'

                    newscope.local('%s = %s' % (pvar,ptype))

            for s in scp.subscopes:
                ns = s.copy_decl(0)
                newscope.add(ns)
            for l in scp.locals: newscope.local(l)
            scp = scp.parent

        self.currentscope = newscope
        return self.currentscope

    #p.parse(vim.current.buffer[:],vim.eval("line('.')"))
    def parse(self,text,curline=0):
        self.curline = int(curline)
        buf = cStringIO.StringIO(''.join(text) + '\n')
        self.gen = tokenize.generate_tokens(buf.readline)
        self.currentscope = self.scope

        try:
            freshscope=True
            while True:
                tokentype, token, indent = self.next()
                #dbg( 'main: token=[%s] indent=[%s]' % (token,indent))

                if tokentype == DEDENT or token == "pass":
                    self.scope = self.scope.pop(indent)
                elif token == 'def':
                    func = self._parsefunction(indent)
                    if func is None:
                        print "function: syntax error..."
                        continue
                    dbg("new scope: function")
                    freshscope = True
                    self.scope = self.scope.add(func)
                elif token == 'class':
                    cls = self._parseclass(indent)
                    if cls is None:
                        print "class: syntax error..."
                        continue
                    freshscope = True
                    dbg("new scope: class")
                    self.scope = self.scope.add(cls)

                elif token == 'import':
                    imports = self._parseimportlist()
                    for mod, alias in imports:
                        loc = "import %s" % mod
                        if len(alias) > 0: loc += " as %s" % alias
                        self.scope.local(loc)
                    freshscope = False
                elif token == 'from':
                    mod, token = self._parsedotname()
                    if not mod or token != "import":
                        print "from: syntax error..."
                        continue
                    names = self._parseimportlist()
                    for name, alias in names:
                        loc = "from %s import %s" % (mod,name)
                        if len(alias) > 0: loc += " as %s" % alias
                        self.scope.local(loc)
                    freshscope = False
                elif tokentype == STRING:
                    if freshscope: self.scope.doc(token)
                elif tokentype == NAME:
                    name,token = self._parsedotname(token)
                    if token == '=':
                        stmt = self._parseassignment()
                        dbg("parseassignment: %s = %s" % (name, stmt))
                        if stmt != None:
                            self.scope.local("%s = %s" % (name,stmt))
                    freshscope = False
        except StopIteration: #thrown on EOF
            pass
        except:
            dbg("parse error: %s, %s @ %s" %
                (sys.exc_info()[0], sys.exc_info()[1], self.parserline))
        return self._adjustvisibility()

def _sanitize(str):
    val = ''
    level = 0
    for c in str:
        if c in ('(','{','['):
            level += 1
        elif c in (']','}',')'):
            level -= 1
        elif level == 0:
            val += c
    return val

sys.path.extend(['.','..'])

def import_and_get_mod(str, parent_mod=None):
    """Attempts to import the supplied string as a module.
    Returns the module that was imported."""
    mods = str.split('.')
    child_mod_str = '.'.join(mods[1:])
    if parent_mod is None:
        if len(mods) > 1:
            #First time this function is called; import the module
            #__import__() will only return the top level module
            return import_and_get_mod(child_mod_str, __import__(str))
        else:
            return __import__(str)
    else:
        mod = getattr(parent_mod, mods[0])
        if len(mods) > 1:
            #We're not yet at the intended module; drill down
            return import_and_get_mod(child_mod_str, mod)
        else:
            return mod

PYTHONEOF
endfunction

call s:DefPython()
" vim: set et ts=4:
