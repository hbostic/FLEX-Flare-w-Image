package com.esri.flare
{

import com.esri.ags.Graphic;
import com.esri.ags.clusterers.supportClasses.Cluster;
import com.esri.ags.events.FlareEvent;

import flash.events.Event;
import flash.events.EventPhase;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.effects.easing.Bounce;
import mx.effects.easing.Linear;

/**
 * UIComponent subclass creating a textfield child to render the weight of the clustered graphics.
 */
internal final class ImageFlareContainer extends UIComponent
{
    private var m_updateDisplayList:Function = updateDisplayListCluster;

    private var m_distance:Number;

    private var m_easing:Function;

    private var m_factor:Number = 0;

    private var m_textField:TextField;

    public var cluster:Cluster;

    public var flareSymbol:ImageFlareSymbol;

    public var flareFactorIncOut:Number = 0.05;

    public var flareFactorIncIn:Number = 0.1;

    public function ImageFlareContainer(flareSymbol:ImageFlareSymbol, cluster:Cluster)
    {
        this.doubleClickEnabled = false;

        this.flareSymbol = flareSymbol;
        this.cluster = cluster;
    }

    override protected function createChildren():void
    {
        super.createChildren();

        m_textField = new TextField();
        m_textField.name = "textField";
        m_textField.mouseEnabled = false;
        m_textField.mouseWheelEnabled = false;
        m_textField.selectable = false;
        m_textField.autoSize = TextFieldAutoSize.CENTER;
        m_textField.text = cluster.weight.toString();

        addChild(m_textField);

        if (cluster.graphics.length < flareSymbol.flareMaxCount)
        {
            addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        }
    }

    private function rollOverHandler(event:MouseEvent):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            removeChild(m_textField);
            addFlares();
            m_factor = 0;
            m_easing = Bounce.easeOut;
            m_updateDisplayList = updateDisplayListFlare;
            addEventListener(Event.ENTER_FRAME, enterFrameOutHandler);
            event.updateAfterEvent();
            mouseChildren = false;
            dispatchEvent(new FlareEvent(FlareEvent.FLARE_OUT_START, cluster));
        }
    }

    private function addFlares():void
    {
        var count:int = 0;
        var start:Number = flareSymbol.ringAngleStart;
        var angle:Number = 0;
        var angleInc:Number = 360.0 / Math.min(flareSymbol.maxCountPerRing, cluster.graphics.length);
        m_distance = flareSymbol.ringDistanceStart;
        for each (var graphic:Graphic in cluster.graphics)
        {
            if (count === flareSymbol.maxCountPerRing)
            {
                count = 0;
                start += flareSymbol.ringAngleInc;
                angle = 0;
                m_distance += flareSymbol.ringDistanceInc;
            }
            addChild(new ImageFlareElement(graphic, start + angle, m_distance));
            angle += angleInc;
            count++;
        }
        swapZ();
    }

    private function swapZ():void
    {
        var i:int = 0;
        var j:int = numChildren - 1;
        while (i < j)
        {
            swapChildrenAt(i++, j--);
        }
    }

    private function enterFrameOutHandler(event:Event):void
    {
        if (m_factor > 1.0)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrameOutHandler);
            mouseChildren = true;
            dispatchEvent(new FlareEvent(FlareEvent.FLARE_OUT_COMPLETE, cluster));
        }
        else
        {
            m_factor += flareFactorIncOut;
            invalidateDisplayList();
        }
    }

    private function rollOutHandler(event:MouseEvent):void
    {
        if (event.eventPhase === EventPhase.AT_TARGET)
        {
            removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            if (m_factor < 1.0)
            {
                removeEventListener(Event.ENTER_FRAME, enterFrameOutHandler);
            }
            else
            {
                m_factor = 1.0;
            }
            m_easing = Linear.easeIn;
            addEventListener(Event.ENTER_FRAME, enterFrameInHandler);
            event.updateAfterEvent();
            mouseChildren = false;
            dispatchEvent(new FlareEvent(FlareEvent.FLARE_IN_START, cluster));
        }
    }

    private function enterFrameInHandler(event:Event):void
    {
        m_factor -= flareFactorIncIn;
        if (m_factor <= 0.0)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrameInHandler);
            removeAllFlares();
            addChild(m_textField);
            m_updateDisplayList = updateDisplayListCluster;
            addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
            dispatchEvent(new FlareEvent(FlareEvent.FLARE_IN_COMPLETE, cluster));
        }
        invalidateDisplayList();
    }

    private function removeAllFlares():void
    {
        while (numChildren)
        {
            removeChildAt(0);
        }
    }

    private function updateDisplayListCluster():void
    {
        if (flareSymbol.textFormat)
        {
            m_textField.embedFonts = FlexGlobals.topLevelApplication.systemManager.isFontFaceEmbedded(flareSymbol.textFormat);
            m_textField.setTextFormat(flareSymbol.textFormat);
        }
        m_textField.x = m_textField.textWidth * -0.5 - 2;
        m_textField.y = m_textField.textHeight * -0.5 - 1;

        graphics.clear();

        if (flareSymbol.backgroundWeights)
        {
            var backgroundColor:Number = flareSymbol.backgroundColor;
            for (var i:int = 0, n:int = flareSymbol.backgroundWeights.length; i < n; i++)
            {
                if (cluster.weight <= flareSymbol.backgroundWeights[i])
                {
                    backgroundColor = flareSymbol.backgroundColors[i];
                    break;
                }
            }

            graphics.beginFill(backgroundColor, flareSymbol.backgroundAlpha * 0.5);
            graphics.drawCircle(0, 0, m_textField.width * 1.2);
            graphics.endFill();

            graphics.beginFill(backgroundColor, flareSymbol.backgroundAlpha);
            graphics.drawCircle(0, 0, m_textField.width * 0.6);
            graphics.endFill();
        }
        else
        {
            if (flareSymbol.borderThickness > 0)
            {
                graphics.lineStyle(flareSymbol.borderThickness, flareSymbol.borderColor, flareSymbol.borderAlpha);
            }

            graphics.beginFill(flareSymbol.backgroundColor, flareSymbol.backgroundAlpha);
            graphics.drawCircle(0, 0, m_textField.width);
            graphics.endFill();
        }
    }

    private function updateDisplayListFlare():void
    {
        graphics.clear();

        // Draw a "large" barely visible circle as a background to enable mouse events over the flared area.
        const radius:Number = Math.max(m_distance, flareSymbol.size);
        graphics.beginFill(0xFFFFFF, 0.01);
        graphics.drawCircle(0, 0, radius + flareSymbol.flareSize);
        graphics.endFill();

        for (var n:int = 0, num:int = numChildren; n < num; n++)
        {
            var flare:ImageFlareElement = ImageFlareElement(getChildAt(n));
            flare.updateFactor(m_easing, m_factor);
            flare.updateDisplayList();
        }
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        m_updateDisplayList();
    }

}

}