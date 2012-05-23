/**
 * @author alteredq / http://alteredqualia.com/
 * @author mr.doob / http://mrdoob.com/
 */

Detector = {

  chrome: window.navigator.userAgent.toLowerCase().indexOf('chrome') > -1,
  canvas: !! window.CanvasRenderingContext2D,
  webgl: ( function () { try { return !! window.WebGLRenderingContext && !! document.createElement( 'canvas' ).getContext( 'experimental-webgl' ); } catch( e ) { return false; } } )(),
  workers: !! window.Worker,
  fileapi: window.File && window.FileReader && window.FileList && window.Blob,

  getNotChromeMessage: function () {

    var element = document.createElement( 'div' );
    element.id = 'webgl-error-message';

    element.innerHTML = 'Sorry, this demo only supports <a href="https://www.google.com/chrome">Google Chrome</a>';

    return element;

  },

  getWebGLErrorMessage: function () {

    var element = document.createElement( 'div' );
    element.id = 'webgl-error-message';

    if ( ! this.webgl ) {

      element.innerHTML = window.WebGLRenderingContext ? [
        'Your graphics card does not seem to support <a href="http://khronos.org/webgl/wiki/Getting_a_WebGL_Implementation">WebGL</a>.<br />',
        'Find out how to get it <a href="http://get.webgl.org/" >here</a>.'
      ].join( '\n' ) : [
        'Your browser does not seem to support <a href="http://khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >WebGL</a>.<br/>',
        'Find out how to get it <a href="http://get.webgl.org/" >here</a>.'
      ].join( '\n' );

    }

    return element;

  },

  addGetWebGLMessage: function ( parameters ) {

    var parent, id, element;

    parameters = parameters || {};

    parent = parameters.parent !== undefined ? parameters.parent : document.body;
    id = parameters.id !== undefined ? parameters.id : 'oldie';

    element = Detector.getWebGLErrorMessage();
    element.id = id;

    parent.appendChild( element );

  }

};
