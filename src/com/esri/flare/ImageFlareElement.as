package com.esri.flare
{

import com.esri.ags.Graphic;
import com.esri.ags.esri_internal;
import com.esri.ags.events.FlareMouseEvent;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.symbols.Symbol;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.MouseEvent;

/**
 * @private
 */
internal final class ImageFlareElement extends Sprite
{
    private var graphic:Graphic;

    private var distance:Number;

    private var m_sprite:Sprite;

    private var m_distance:Number;

    public function ImageFlareElement(graphic:Graphic, angle:Number, distance:Number)
    {
        this.mouseEnabled = false;
        this.mouseChildren = true;

        this.graphic = graphic;
        this.distance = distance;
        this.rotation = angle;

        this.addEventListener(Event.REMOVED, this_removedHandler);

        m_sprite = new Sprite();
        m_sprite.addEventListener(Event.REMOVED, sprite_removedHandler, false, 0, true);
        m_sprite.addEventListener(MouseEvent.MOUSE_DOWN, sprite_mouseDownHandler, false, 0, true);
        addChild(m_sprite);
    }

    private function this_removedHandler(event:Event):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            removeChild(m_sprite);
        }
    }

    private function sprite_mouseDownHandler(event:MouseEvent):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            m_sprite.addEventListener(MouseEvent.MOUSE_MOVE, sprite_mouseMoveHandler, false, 0, true);
            m_sprite.addEventListener(MouseEvent.MOUSE_UP, sprite_mouseUpHandler, false, 0, true);
        }
    }

    private function sprite_mouseMoveHandler(event:MouseEvent):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            m_sprite.removeEventListener(MouseEvent.MOUSE_MOVE, sprite_mouseMoveHandler);
            m_sprite.removeEventListener(MouseEvent.MOUSE_UP, sprite_mouseUpHandler);
        }
    }

    private function sprite_mouseUpHandler(event:MouseEvent):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            event.stopPropagation();
            m_sprite.removeEventListener(MouseEvent.MOUSE_MOVE, sprite_mouseMoveHandler);
            m_sprite.removeEventListener(MouseEvent.MOUSE_UP, sprite_mouseUpHandler);
            dispatchFlareMouseEvent(FlareMouseEvent.FLARE_CLICK, event, ImageFlareContainer(parent));
        }
    }

    private function dispatchFlareMouseEvent(type:String, event:MouseEvent, flareContainer:ImageFlareContainer):void
    {
        const clusterMouseEvent:FlareMouseEvent = new FlareMouseEvent(type, flareContainer.cluster, graphic);
        clusterMouseEvent.esri_internal::copyProperties(event);
        dispatchEvent(clusterMouseEvent);
    }

    private function sprite_removedHandler(event:Event):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            m_sprite.removeEventListener(MouseEvent.MOUSE_DOWN, sprite_mouseDownHandler);
            m_sprite.removeEventListener(MouseEvent.MOUSE_MOVE, sprite_mouseMoveHandler);
            m_sprite.removeEventListener(MouseEvent.MOUSE_UP, sprite_mouseUpHandler);
        }
    }

    public function updateFactor(easing:Function, factor:Number):void
    {
        m_distance = easing(factor, 0, distance, 1.0);
    }

    private function getLayerSymbol(container:ImageFlareContainer):Symbol
    {
        var dispObj:DisplayObject = container.parent;
        while (dispObj)
        {
            const graphicsLayer:GraphicsLayer = dispObj as GraphicsLayer;
            if (graphicsLayer)
            {
                return graphicsLayer.symbol;
            }
            dispObj = dispObj.parent;
        }
        return null;
    }

    public function updateDisplayList():void
    {
        const flareContainer:ImageFlareContainer = ImageFlareContainer(parent);
        const flareSymbol:ImageFlareSymbol = flareContainer.flareSymbol;

        graphics.clear();
        graphics.lineStyle(flareSymbol.borderThickness, flareSymbol.borderColor, flareSymbol.borderAlpha);
        graphics.moveTo(0, 0);
        graphics.lineTo(m_distance, 0);

        m_sprite.x = m_distance;
        m_sprite.y = 0;
        m_sprite.rotation = -rotation;
		
		//<!--modified by Alex Begin changed to create new ImageFlareElementSymbol since -->
		//<!-- one can't be passed like Graphics Layer example by Mansour -->
        //const graphicSymbol:ImageFlareElementSymbol = graphic.symbol as ImageFlareElementSymbol;
		const graphicSymbol:ImageFlareElementSymbol = new ImageFlareElementSymbol();
		//<!--modified by Alex End -->
        if (graphicSymbol)
        {
            graphicSymbol.draw(m_sprite, graphic.geometry, graphic.attributes, null);
        }
        else
        {
            const layerSymbol:Symbol = getLayerSymbol(flareContainer);
            if (layerSymbol)
            {
                layerSymbol.draw(m_sprite, graphic.geometry, graphic.attributes, null);
            }
        }
    }
}

}