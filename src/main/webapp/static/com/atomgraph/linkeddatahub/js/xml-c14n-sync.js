(()=>{var e={237:(e,t,n)=>{var r=n(291),i={algorithms:{"http://www.w3.org/2001/10/xml-exc-c14n#":function(e){return new r(e)},"http://www.w3.org/2001/10/xml-exc-c14n#WithComments":function(e){return(e=Object.create(e||null)).includeComments=!0,new r(e)}}},o=e.exports=function e(){if(!(this instanceof e))return new e;this.algorithms=Object.create(i.algorithms)};o.prototype.registerAlgorithm=function(e,t){return this.algorithms[e]=t,this},o.prototype.getAlgorithm=function(e){return this.algorithms[e]},o.prototype.createCanonicaliser=function(e,t){return this.algorithms[e](t)}},936:e=>{var t=e.exports=function(e){};t.prototype.name=function(){return null},t.prototype.canonicalise=function(e,t){setImmediate((function(){return t(Error("not implemented"))}))},t.prototype.canonicaliseSync=function(e){throw Error("not implemented")}},291:(e,t,n)=>{var r=n(418),i=n(936),o=e.exports=function(e){i.call(this,e),e=e||{},this.includeComments=!!e.includeComments,this.inclusiveNamespaces=e.inclusiveNamespaces||[]};o.prototype=Object.create(i.prototype,{constructor:{value:o}}),o.prototype.name=function(){return"http://www.w3.org/2001/10/xml-exc-c14n#"+(this.includeComments?"WithComments":"")},o.prototype.canonicalise=function(e,t){var n=this;setImmediate((function(){try{var r=n._processInner(e)}catch(e){return t(e)}return t(null,r)}))},o.prototype.canonicaliseSync=function(e){return self._processInner(e)},o.prototype.getIncludeComments=function(){return!!this.includeComments},o.prototype.setIncludeComments=function(e){this.includeComments=!!e},o.prototype.getInclusiveNamespaces=function(){return this.inclusiveNamespaces.slice()},o.prototype.setInclusiveNamespaces=function(e){return this.inclusiveNamespaces=e.slice(),this},o.prototype.addInclusiveNamespace=function(e){return this.inclusiveNamespaces.push(e),this};var s=function(e,t){return!e.prefix&&t.prefix?-1:!t.prefix&&e.prefix?1:e.name.localeCompare(t.name)},a=function(e,t){var n=e.prefix+e.namespaceURI,r=t.prefix+t.namespaceURI;return n===r?0:n.localeCompare(r)};o.prototype._renderAttributes=function(e){return(e.attributes?[].slice.call(e.attributes):[]).filter((function(e){return 0!==e.name.indexOf("xmlns")})).sort(s).map((function(e){return" "+e.name+'="'+r.attributeEntities(e.value)+'"'})).join("")},o.prototype._renderNamespace=function(e,t,n){var i="",o=n,s=t.slice(),c=[],u=e.namespaceURI||"";if(e.prefix){if((m=s.filter((function(t){return t.prefix===e.prefix})).shift())&&m.namespaceURI!==e.namespaceURI){for(var p=0;p<s.length;++p)s[p].prefix===e.prefix&&s.splice(p--,1);m=null}m||(c.push({prefix:e.prefix,namespaceURI:e.namespaceURI}),s.push({prefix:e.prefix,namespaceURI:e.namespaceURI}))}else n!==u&&(o=u,i+=' xmlns="'+r.attributeEntities(o)+'"');if(e.attributes)for(p=0;p<e.attributes.length;p++){var l=e.attributes[p],m=null;if(l.prefix&&"xmlns"!==l.prefix&&(m=s.filter((function(e){return e.prefix===l.prefix})).shift())&&m.namespaceURI!==l.namespaceURI){for(p=0;p<s.length;++p)s[p].prefix===l.prefix&&s.splice(p--,1);m=null}l.prefix&&!m&&"xmlns"!==l.prefix?(c.push({prefix:l.prefix,namespaceURI:l.namespaceURI}),s.push({prefix:l.prefix,namespaceURI:l.namespaceURI})):l.prefix&&"xmlns"===l.prefix&&-1!==this.inclusiveNamespaces.indexOf(l.localName)&&c.push({prefix:l.localName,namespaceURI:l.nodeValue})}for(c.sort(a),p=0;p<c.length;++p)i+=" xmlns:"+c[p].prefix+'="'+r.attributeEntities(c[p].namespaceURI)+'"';return{rendered:i,newDefaultNamespace:o,newPrefixesInScope:s}},o.prototype._renderComment=function(e){var t=null,n=null;if(e.ownerDocument===e.parentNode){for(var i=e,o=e;null!==i;){if(i===e.ownerDocument.documentElement){t=!0;break}i=i.nextSibling}for(;null!==o;){if(o===e.ownerDocument.documentElement){n=!0;break}o=o.previousSibling}}return(n?"\n":"")+"\x3c!--"+r.textEntities(e.data)+"--\x3e"+(t?"\n":"")},o.prototype._renderProcessingInstruction=function(e){if("xml"===e.tagName)return"";var t=null,n=null;if(e.ownerDocument===e.parentNode){for(var i=e,o=e;null!==i;){if(i===e.ownerDocument.documentElement){t=!0;break}i=i.nextSibling}for(;null!==o;){if(o===e.ownerDocument.documentElement){n=!0;break}o=o.previousSibling}}return(n?"\n":"")+"<?"+e.tagName+(e.data?" "+r.textEntities(e.data):"")+"?>"+(t?"\n":"")},o.prototype._processInner=function(e,t,n){if(n=n||"",t=t||[],3===e.nodeType)return e.ownerDocument===e.parentNode?r.textEntities(e.data.trim()):r.textEntities(e.data);if(7===e.nodeType)return this._renderProcessingInstruction(e);if(8===e.nodeType)return this.includeComments?this._renderComment(e):"";if(10===e.nodeType)return"";var i=this._renderNamespace(e,t,n),o=this;return[e.tagName?"<"+e.tagName+i.rendered+this._renderAttributes(e)+">":"",[].slice.call(e.childNodes).map((function(e){return o._processInner(e,i.newPrefixesInScope,i.newDefaultNamespace)})).join(""),e.tagName?"</"+e.tagName+">":""].join("")}},418:(e,t)=>{var n=t.entities={"&":"&amp;",'"':"&quot;","<":"&lt;",">":"&gt;","\t":"&#x9;","\n":"&#xA;","\r":"&#xD;"};t.attributeEntities=function(e){return e.replace(/([\&<"\t\n\r])/g,(function(e){return n[e]}))},t.textEntities=function(e){return e.replace(/([\&<>\r])/g,(function(e){return n[e]}))}}},t={},n=function n(r){var i=t[r];if(void 0!==i)return i.exports;var o=t[r]={exports:{}};return e[r](o,o.exports,n),o.exports}(237);window["xml-c14n-sync.js"]=n})();