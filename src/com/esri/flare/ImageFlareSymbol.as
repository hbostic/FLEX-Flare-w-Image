package com.esri.flare
{

import com.esri.ags.Map;
import com.esri.ags.clusterers.supportClasses.ClusterGraphic;
import com.esri.ags.esri_internal;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.symbols.Symbol;

import flash.display.Sprite;
import flash.text.TextFormat;

import mx.core.UIComponent;

use namespace esri_internal;

//--------------------------------------
//  Other metadata
//--------------------------------------

public class ImageFlareSymbol extends Symbol
{
    private var m_size:Number = 15;
    private var m_backgroundColor:Number = 0x76D100;
    private var m_backgroundAlpha:Number = 1.0;
    private var m_borderThickness:Number = 1;
    private var m_borderColor:Number = 0x000000;
    private var m_borderAlpha:Number = 1.0;
    private var m_flareMaxCount:int = 30;
    private var m_maxCountPerRing:int = 6;
    private var m_ringAngleStart:Number = 5.0;
    private var m_ringAngleInc:Number = 15.0;
    private var m_ringDistanceStart:Number = 30.0;
    private var m_ringDistanceInc:Number = 20.0;
    private var m_flareSize:Number = 5;
    private var m_flareSizeIncOnRollOver:Number = 2;
    private var m_textFormat:TextFormat;
    private var m_backgroundWeights:Array;
    private var m_backgroundColors:Array;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Creates a new ImageFlareSymbol instance.
     */
    public function ImageFlareSymbol()
    {
    }


    [Bindable]
    /**
     * Renderering weight limits
     */
    public final function get backgroundWeights():Array
    {
        return m_backgroundWeights;
    }

    /**
     * @private
     */
    public final function set backgroundWeights(value:Array):void
    {
        m_backgroundWeights = value;
    }

    [Bindable]
    /**
     * The associated colors for limits.
     */
    public final function get backgroundColors():Array
    {
        return m_backgroundColors;
    }

    /**
     * @private
     */
    public final function set backgroundColors(value:Array):void
    {
        m_backgroundColors = value;
    }


    [Bindable]
    /**
     * The max number of cluster elements to flare.
     * If a cluster has a set of graphics less that this count, and when the user rolls over
     * the cluster, then it will flare.
     *
     * @default 30 graphics
     */
    public function get flareMaxCount():int
    {
        return m_flareMaxCount;
    }

    /**
     * @private
     */
    public function set flareMaxCount(value:int):void
    {
        if (m_flareMaxCount !== value)
        {
            m_flareMaxCount = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The size of the center circle, in pixels.
     * @default 15 pixels
     */
    public function get size():Number
    {
        return m_size;
    }

    /**
     * @private
     */
    public function set size(value:Number):void
    {
        if (m_size !== value)
        {
            m_size = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The text format.
     * @default null
     */
    public function get textFormat():TextFormat
    {
        return m_textFormat;
    }

    /**
     * @private
     */
    public function set textFormat(value:TextFormat):void
    {
        if (m_textFormat !== value)
        {
            m_textFormat = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The border alpha. Possible values range from 0.0 (invisible, fully transparent) to 1.0 (opaque, fully visible).
     * @default 1.0 (opaque, fully visible)
     */
    public function get borderAlpha():Number
    {
        return m_borderAlpha;
    }

    /**
     * @private
     */
    public function set borderAlpha(value:Number):void
    {
        if (m_borderAlpha !== value)
        {
            m_borderAlpha = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    [Inspectable(format="Color")]
    /**
     * The border color of the FlareSymbol.
     * @default 0x000000 (black)
     */
    public function get borderColor():Number
    {
        return m_borderColor;
    }

    /**
     * @private
     */
    public function set borderColor(value:Number):void
    {
        if (m_borderColor !== value)
        {
            m_borderColor = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The border thickness of the FlareSymbol, in pixels.
     * @default 2 pixels
     */
    public function get borderThickness():Number
    {
        return m_borderThickness;
    }

    /**
     * @private
     */
    public function set borderThickness(value:Number):void
    {
        if (m_borderThickness !== value)
        {
            m_borderThickness = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The background alpha of the FlareSymbol.  Possible values range from 0.0 (invisible, fully transparent) to 1.0 (opaque, fully visible).
     * @default 1.0 (opaque, fully visible)
     */
    public function get backgroundAlpha():Number
    {
        return m_backgroundAlpha;
    }

    /**
     * @private
     */
    public function set backgroundAlpha(value:Number):void
    {
        if (m_backgroundAlpha !== value)
        {
            m_backgroundAlpha = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    [Inspectable(format="Color")]
    /**
     * The background color of the FlareSymbol.
     * @default 0x76D100 (turtle green)
     */
    public function get backgroundColor():Number
    {
        return m_backgroundColor;
    }

    /**
     * @private
     */
    public function set backgroundColor(value:Number):void
    {
        if (m_backgroundColor !== value)
        {
            m_backgroundColor = value;
            dispatchEventChange();
        }
    }

    /**
     * Initialize the sprite.
     *
     * @private
     */
    override public function initialize(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
    {
        const clusterGraphic:ClusterGraphic = sprite as ClusterGraphic;
        if (clusterGraphic)
        {
            sprite.addChild(new ImageFlareContainer(this, clusterGraphic.cluster));
        }
    }

    /**
     * Clear the sprite graphics.
     *
     * @private
     */
    override public function clear(sprite:Sprite):void
    {
        sprite.graphics.clear();
    }

    /**
     * Draw the sprite at a specific screen coordinate.
     *
     * @private
     */
    override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
    {
        const clusterGraphic:ClusterGraphic = sprite as ClusterGraphic;
        if (clusterGraphic)
        {
            const mapPoint:MapPoint = clusterGraphic.mapPoint;
            sprite.x = toScreenX(map, mapPoint.x);
            sprite.y = toScreenY(map, mapPoint.y);
        }
    }

    /**
     * Release any allocated resources during intialization.
     *
     * @private
     */
    override public function destroy(sprite:Sprite):void
    {
        removeAllChildren(sprite);
    }

    [Bindable]
    /**
     * Max count of flare elements per ring.
     *
     * @default 6 elements
     */
    public function get maxCountPerRing():int
    {
        return m_maxCountPerRing;
    }

    /**
     * @private
     */
    public function set maxCountPerRing(value:int):void
    {
        if (m_maxCountPerRing !== value)
        {
            m_maxCountPerRing = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * Flare ring initial angle value.
     *
     * @default 5
     */
    public function get ringAngleStart():Number
    {
        return m_ringAngleStart;
    }

    /**
     * @private
     */
    public function set ringAngleStart(value:Number):void
    {
        if (m_ringAngleStart !== value)
        {
            m_ringAngleStart = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * Additional flare ring angle increment value.
     *
     * @default 15
     */
    public function get ringAngleInc():Number
    {
        return m_ringAngleInc;
    }

    /**
     * @private
     */
    public function set ringAngleInc(value:Number):void
    {
        if (m_ringAngleInc !== value)
        {
            m_ringAngleInc = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * Flare ring initial distance.
     *
     * @private 30
     */
    public function get ringDistanceStart():Number
    {
        return m_ringDistanceStart;
    }

    /**
     * @private
     */
    public function set ringDistanceStart(value:Number):void
    {
        if (m_ringDistanceStart !== value)
        {
            m_ringDistanceStart = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * Additional flare ring incremental distance value.
     *
     * @default 20 pixels
     */
    public function get ringDistanceInc():Number
    {
        return m_ringDistanceInc;
    }

    /**
     * @private
     */
    public function set ringDistanceInc(value:Number):void
    {
        if (m_ringDistanceInc !== value)
        {
            m_ringDistanceInc = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The flare element radius.
     *
     * @default 5 pixels
     */
    public function get flareSize():Number
    {
        return m_flareSize;
    }

    /**
     * @private
     */
    public function set flareSize(value:Number):void
    {
        if (m_flareSize !== value)
        {
            m_flareSize = value;
            dispatchEventChange();
        }
    }

    [Bindable]
    /**
     * The flare element radius increment when the user rolls over it.
     *
     * @default 2 pixels
     */
    public function get flareSizeIncOnRollOver():Number
    {
        return m_flareSizeIncOnRollOver;
    }

    /**
     * @private
     */
    public function set flareSizeIncOnRollOver(value:Number):void
    {
        if (m_flareSizeIncOnRollOver !== value)
        {
            m_flareSizeIncOnRollOver = value;
            dispatchEventChange();
        }
    }

    /**
     * @private
     */
    override public function createSwatch(width:Number = 50, height:Number = 50):UIComponent
    {
        const swatch:UIComponent = new UIComponent();
        swatch.width = width;
        swatch.height = height;

        const radius:Number = Math.min(width, height) * 0.5;
        if (borderThickness > 0)
        {
            swatch.graphics.lineStyle(borderThickness, borderColor, borderAlpha);
        }
        swatch.graphics.beginFill(backgroundColor, backgroundAlpha);
        swatch.graphics.drawCircle(width * 0.5, height * 0.5, radius);
        swatch.graphics.endFill();

        return swatch;
    }

}

}