package com.esri.flare
{

import com.esri.ags.Map;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.symbols.Symbol;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

public class ImageFlareElementSymbol extends Symbol
{
    private static const bitmapDataDict:Dictionary = new Dictionary();

    [Embed(source="assets/error.png")]
    private static var ERROR_CLASS:Class;

    private const m_matrix:Matrix = new Matrix();
    private var m_queue:Array;

    public var href:String;
    public var rotation:Number = 0.0;
    public var scale:Number = 1.0;
    public var hotSpotX:Number = Number.NaN;
    public var hotSpotY:Number = Number.NaN;

    public function ImageFlareElementSymbol()
    {
    }

    override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
    {
        const mapPoint:MapPoint = geometry as MapPoint;
		
		//<!--Added by Alex Begin handle href being null -->
		if (href == null)
		{
			href = "assets/error.png"
		}
		//<!--Added by Alex End -->
		
        const bitmapData:BitmapData = bitmapDataDict[href];
        if (bitmapData)
        {
            drawPoint(map, sprite, mapPoint, bitmapData);
        }
        else
        {
            if (m_queue)
            {
                m_queue.push({ sprite: sprite, mapPoint: mapPoint });
            }
            else
            {
                m_queue = [{ sprite: sprite, mapPoint: mapPoint }];

                const urlRequest:URLRequest = new URLRequest(href);

                const loaderContext:LoaderContext = new LoaderContext();
                loaderContext.checkPolicyFile = true;

                const loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                loader.load(urlRequest, loaderContext);
                function completeHandler(event:Event):void
                {
                    const loaderInfo:LoaderInfo = event.target as LoaderInfo;
                    const content:Bitmap = loaderInfo.content as Bitmap;
                    bitmapDataDict[href] = content.bitmapData;
                    for each (var obj:Object in m_queue)
                    {
                        drawPoint(map, obj.sprite, obj.mapPoint, content.bitmapData);
                    }
                    m_queue = null;
                }
                function ioErrorHandler(event:IOErrorEvent):void
                {
                    const content:Bitmap = new ERROR_CLASS();
                    bitmapDataDict[href] = content.bitmapData;
                    for each (var obj:Object in m_queue)
                    {
                        drawPoint(map, obj.sprite, obj.mapPoint, content.bitmapData);
                    }
                    m_queue = null;
                }

            }
        }
    }

    private function drawPoint(map:Map, sprite:Sprite, mapPoint:MapPoint, bitmapData:BitmapData):void
    {
        if (sprite.parent is GraphicsLayer)
        {
            sprite.x = toScreenX(map, mapPoint.x);
            sprite.y = toScreenY(map, mapPoint.y);
        }

        sprite.rotation += rotation;
        sprite.scaleX = scale;
        sprite.scaleY = scale;

        m_matrix.a = 1.0;
        m_matrix.d = 1.0;
        if (isNaN(hotSpotX) && isNaN(hotSpotY))
        {
            m_matrix.tx = (0.0 - bitmapData.width / 2.0);
            m_matrix.ty = (0.0 - bitmapData.height / 2.0);
        }
        else
        {
            m_matrix.tx = (0.0 - hotSpotX);
            m_matrix.ty = (hotSpotY - bitmapData.height);
        }

        sprite.graphics.clear();
        sprite.graphics.beginBitmapFill(bitmapData, m_matrix, false, true);
        sprite.graphics.drawRect(m_matrix.tx, m_matrix.ty, bitmapData.width, bitmapData.height);
        sprite.graphics.endFill();
    }

}

}