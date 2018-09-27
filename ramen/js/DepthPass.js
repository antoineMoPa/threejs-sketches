(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        define('three.SavePass', ['three'], factory);
    }
    else if ('undefined' !== typeof exports && 'undefined' !== typeof module) {
        module.exports = factory(require('three'));
    }
    else {
        factory(root.THREE);
    }
}(this, function(THREE) {


/**
 * Depth Pass Made from Bokeh Pass example
 * And SavePass example:
 * @author alteredq / http://alteredqualia.com/
 * @author antoineMoPa
 */

THREE.DepthPass = function ( scene, camera ) {
	
	THREE.Pass.call( this );

	this.scene = scene;
	this.camera = camera;

	var width = window.innerWidth || 1;
	var height = window.innerHeight || 1;
	
	this.renderTarget = new THREE.WebGLRenderTarget( width, height, {
		minFilter: THREE.LinearFilter,
		magFilter: THREE.LinearFilter,
		format: THREE.RGBAFormat
	} );
		
	this.renderTarget.texture.name = "DepthPass.depth";

	this.needsSwap = false;
	
	this.materialDepth = new THREE.MeshDepthMaterial();
	this.materialDepth.depthPacking = THREE.RGBADepthPacking;
	
	this.oldClearColor = new THREE.Color();
	this.oldClearAlpha = 1;
};

THREE.DepthPass.prototype = Object.assign( Object.create( THREE.Pass.prototype ), {

	constructor: THREE.DepthPass,

	render: function ( renderer, writeBuffer, readBuffer ) {

		// Render depth into texture
		this.scene.overrideMaterial = this.materialDepth;

		this.oldClearColor.copy( renderer.getClearColor() );
		this.oldClearAlpha = renderer.getClearAlpha();
		var oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

		renderer.setClearColor( 0xffffff );
		renderer.setClearAlpha( 1.0 );

		renderer.render( this.scene, this.camera, this.renderTarget, true);

		this.scene.overrideMaterial = null;
		renderer.setClearColor( this.oldClearColor );
		renderer.setClearAlpha( this.oldClearAlpha );
		renderer.autoClear = this.oldAutoClear;
	}

} );
}));
