function citoBuildTree(nodes) {
    var children = [];
    for (var i = 0; i < nodes.length; i++) {
        var n = nodes[i];
        if (n.children !== null) {
            children.push({tag: 'div', key: n.key, children: citoBuildTree(n.children)});
        } else {
            children.push({tag: 'span', key: n.key, children: n.key.toString()});
        }
    }
    return children;
}

function Benchmark(a, b, container) {
    this._a = a;
    this._b = b;
    this._container = container;
}

Benchmark.prototype.setUp = function() {
};

Benchmark.prototype.tearDown = function() {
    cito.vdom.remove(this._node);
};

Benchmark.prototype.render = function() {
    this._node = cito.vdom.append(this._container, {tag: "div", children: citoBuildTree(this._a)});
};

Benchmark.prototype.update = function() {
    cito.vdom.update(this._node, {tag: "div", children: citoBuildTree(this._b)})
};

module.exports = Benchmark;

var cito=window.cito||{};!function(e,t,r){"use strict";function n(e){return"string"==typeof e}function i(e){return e instanceof Array}function a(e){return"function"==typeof e}function o(e,t){var r=typeof e;return"string"===r?{tag:"#",children:e}:"function"===r?o(e(t),t):e}function f(e,t,r){var n=e[t],i=o(n,r);return n!==i&&(e[t]=i),i}function l(e){var t=i(e)?e[0]:e;return o(t)}function u(e,t){var r=l(e);return r&&!r.dom&&(r.dom=t.firstChild),r}function c(e,t,r){return t&&a(t)&&(e.children=t=t(r)),t}function s(e,t){H?e.textContent=t:e.innerText=t}function v(e,t,r){r?e.insertBefore(t,r.dom):e.appendChild(t)}function d(e,t){var r,n=e.tag,i=e.children;switch(n){case"#":r=V.createTextNode(i);break;case"!":r=V.createComment(i);break;case"<":if(i){F.innerHTML=i;for(var a,o=V.createDocumentFragment();a=F.firstChild;)o.appendChild(a);return e.dom=o.firstChild,e.domSize=o.childNodes.length,o}r=V.createTextNode("");break;default:var f;switch(n){case"svg":f="http://www.w3.org/2000/svg";break;case"math":f="http://www.w3.org/1998/Math/MathML";break;default:f=t&&t.ns}f?(e.ns=f,r=V.createElementNS(f,n)):r=V.createElement(n),h(r,null,null,e,n,e.attrs,e.events),b(r,e,c(e,i))}return e.dom=r,r}function h(e,t,n,i,a,o,f){var l;if(o)for(l in o){var u=o[l];if("style"===l){var c=t&&t[l];c!==u&&m(e,c,o,u)}else if(p(a,l))e[l]!==u&&(e[l]=u);else if(!t||t[l]!==u)if(u===!1)e.removeAttribute(l);else{u===!0&&(u="");var s,v=l.indexOf(":");if(-1!==v){var d=l.substr(0,v);switch(d){case"xlink":s="http://www.w3.org/1999/xlink"}}s?e.setAttributeNS(s,l,u):e.setAttribute(l,u)}}if(t)for(l in t)o&&o[l]!==r||(p(a,l)?e[l]="":e.removeAttribute(l));var h;if(f){e.virtualNode=i;for(h in f)n&&n[h]||g(e,h)}if(n)for(h in n)f&&f[h]||k(e,h)}function m(e,t,i,a){var o;if(!(n(a)||G&&t&&!n(t))){var f="";if(a)for(o in a)f+=o+": "+a[o]+"; ";a=f,G||(i.style=a)}var l=e.style;if(n(a))l.cssText=a;else{if(a)for(o in a){var u=a[o];if(!t||t[o]!==u){var c=u.indexOf("!important");if(-1!==c)l.setProperty(o,u.substr(0,c),"important");else{if(t){var s=t[o];s&&-1!==s.indexOf("!important")&&l.removeProperty(o)}l.setProperty(o,u,"")}}}if(t)for(o in t)a&&a[o]!==r||l.removeProperty(o)}}function p(e,t){switch(e){case"input":return"value"===t||"checked"===t;case"textarea":return"value"===t;case"select":return"selectedIndex"===t;case"option":return"selected"===t}}function g(e,t){if(j)e.addEventListener(t,L,!1);else{var r="on"+t;r in e?e[r]=L:e.attachEvent(r,L)}}function k(e,t){if(j)e.removeEventListener(t,L,!1);else{var r="on"+t;r in e?e[r]=null:e.detachEvent(r,L)}}function y(e,t,r,n){var i=w(r);if(0===i)b(e,t,n);else{var a=w(n);if(0===a)1===i?null!==N(r)?e.removeChild(e.firstChild):E(e,u(r,e)):i>1&&(r=x(r,i,e),P(e,r,0,i));else if(1===i&&1===a){var o,f=N(r);if(null!==f&&null!==(o=N(n)))f!==o&&s(e,o);else{var c=u(r,e),v=l(n);D(c,v,t,e)}}else r=x(r,i,e),n=C(n,a,t),S(e,t,r,n)}}function b(e,t,r){var n=w(r);if(1===n){var i=N(r);null!==i?s(e,i):e.appendChild(d(l(r),t))}else if(n>1){r=C(r,n,t);for(var a=0,o=r.length;o>a;a++)e.appendChild(d(f(r,a),t))}}function w(e){return i(e)?e.length:e||n(e)?1:0}function x(e,t,r){if(e=t>1?e:i(e)?e:[e],1===t){var n=f(e,0);n.dom||(n.dom=r.firstChild)}return e}function C(e,t,r){return t>1?e:i(e)?e:r.children=[e]}function N(e){var t=i(e)?e[0]:e;return n(t)?t:"#"===t.tag?t.children:null}function P(e,t,r,n){var i,a=n-r;if(1===a)E(e,t[r]);else for(i=r;n>i;i++)E(e,t[i])}function E(e,t){M(t);for(var r,n=t.dom,i=t.domSize||1;i--;)r=i>0?n.nextSibling:null,e.removeChild(n),n=r}function S(e,t,r,n){var i=0,a=r.length-1,o=0,l=n.length-1,u=!0;e:for(;u&&a>=i&&l>=o;){u=!1;var c,s,h,m;for(c=r[i],h=f(n,o,c);c.key===h.key;){if(D(c,h,t),i++,o++,i>a||o>l)break e;c=r[i],h=f(n,o,c),u=!0}for(s=r[a],m=f(n,l,s);s.key===m.key;){if(D(s,m,t),a--,l--,i>a||o>l)break e;s=r[a],m=f(n,l),u=!0}for(;c.key===m.key;){if(D(c,m,t),v(e,m.dom,n[l+1]),i++,l--,i>a||o>l)break e;c=r[i],m=f(n,l),u=!0}for(;s.key===h.key;){if(D(s,h,t),e.insertBefore(h.dom,r[i].dom),a--,o++,i>a||o>l)break e;s=r[a],h=f(n,o),u=!0}}if(i>a)for(f(n,o);l>=o;o++)v(e,d(n[o],t),f(n,l+1));else if(o>l)P(e,r,i,a+1);else{var p,g,k=r[a+1],y={};for(p=a;p>=i;p--)g=r[p],g.next=k,y[g.key]=g,k=g;var b=f(n,l+1);for(p=l;p>=o;p--){var w=n[p],x=w.key;if(g=y[x]){y[x]=null,k=g.next;var C=D(g,w,t);(k&&k.key)!==(b&&b.key)&&v(e,C,b)}else v(e,d(w,t),b);b=w}for(p=i;a>=p;p++)g=r[p],null!==y[g.key]&&E(e,g)}}function T(){J=!0,this.stopPropagation()}function A(){this.defaultPrevented=!0,this.returnValue=!1}function B(){this.cancelBubble=!0}function L(e){e||(e=t.event),e.defaultPrevented===r&&(e.defaultPrevented=e.returnValue===!1),e.preventDefault||(e.preventDefault=A),e.stopPropagation||(e.stopPropagation=B),J=!1,e.stopImmediatePropagation=T;var n=e.currentTarget;n||(n=this.tagName?this:e.srcElement);var a=n.virtualNode.events[e.type];if(i(a))for(var o=0,f=a.length;f>o&&(z(a[o],e),!J);o++);else z(a,e)}function z(e,t){try{e(t)===!1&&t.preventDefault()}catch(r){R.error(r.stack||r)}}function D(e,t,r){var n,i,a,o=e.dom,f=t.tag;if(e.tag!==f){n=o.parentNode;var l=o;if(o=d(t,r),M(e),n)if(i=e.domSize,i>1)for(n.insertBefore(o,l);i--;)a=i>0?l.nextSibling:null,n.removeChild(l),l=a;else n.replaceChild(o,l)}else{var u=e.children,s=t.children;switch(f){case"#":case"!":u!==s&&(o.nodeValue=s);break;case"<":if(u!==s)for(n=o.parentNode,n.insertBefore(d(t),o),i=e.domSize||1;i--;)a=i>0?o.nextSibling:null,n.removeChild(o),o=a;break;default:h(o,e.attrs,e.events,t,f,t.attrs,t.events),y(o,t,u,c(t,s,u))}}return t.dom=o,o}function M(e){var t=e.dom,n=e.events;if(n)for(var a in n)k(t,a);t.virtualNode&&(t.virtualNode=r);var o=e.children;if(o)if(i(o))for(var f=0,l=o.length;l>f;f++){var u=o[f];u.tag&&M(u)}else o.tag&&M(o)}function O(e,t){var n;for(n in e)t[n]=e[n];for(n in t)e[n]===r&&(t[n]=r)}var V=t.document,I=function(){},R=t.console||{warn:I,error:I},F=V.createElement("div"),H="textContent"in V,j="addEventListener"in V,q="createRange"in V,G="setProperty"in F.style,J=(q?V.createRange():null,!1),K=e.vdom={create:function(e){return e=o(e),d(e),e},append:function(e,t){return t=K.create(t),e.appendChild(t.dom),t},update:function(e,t){return t=o(t,e),D(e,t),O(t,e),e},remove:function(e){var t=e.dom.parentNode;E(t,e)}}}(cito,window);