
SVGraph_Attach(ActiveX := False){
	Static IE
	if(ActiveX){
		IE := ActiveX
	}
	return IE
}

SVGraph_Start(){
	SVGraph_Attach().Navigate(A_ScriptDir "\SVGraph.html")
	While SVGraph_Attach().ReadyState != 4 || SVGraph_Attach().Busy {
		Sleep, 20
	}
}

SVGraph_Chart(Width, Height, Margin := 40){
	Width := (__IsNum(Width) ? Width : 500), Height := (__IsNum(Height) ? Height : 500), Margin := (__IsNum(Margin) ? Margin : 40)
	SVGraph_Attach().Document.parentWindow.eval("var plot = new Chart(" Width "," Height "," Margin ");")
}

SVGraph_UpdateChart(Width := "", Height := "", Margin := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Update(" __IsDefined(Width) "," __IsDefined(Height) "," __IsDefined(Margin) ");")
}

SVGraph_SetAxes(xmin := "", xmax := "", ymin := "", ymax := "", Boxed := False){
	xmin := __IsDefinedNum(xmin), xmax := __IsDefinedNum(xmax), ymin := __IsDefinedNum(ymin), ymax := __IsDefinedNum(ymax)
	SVGraph_Attach().Document.parentWindow.eval("plot.SetAxes(" xmin "," xmax "," ymin "," ymax "," Boxed ");")
}

SVGraph_SetLables(xLable := "", yLable := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.SetLables(" __IsDefined("""" xLable """") "," __IsDefined("""" yLable """") ");")
}

SVGraph_SetGrid(xory := "", Major := "", Minor := "", Colour := "", DashArray := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.SetGrid(""" xory """," __IsDefined(Major) "," __IsDefined(Minor) "," __IsDefined("""" Colour """") "," __IsDefined("""" DashArray """") ");")
}

SVGraph_ShowScrollbar(Bool := False){
	SVGraph_Attach().Document.body.style.overflow := Bool ? "visible" : "hidden"
}

SVGraph_ShowGrid(Bool := True){
	SVGraph_Attach().Document.parentWindow.eval("plot.Axes.Grid(" (Bool = True) ");")
}

SVGraph_Group(ID){
	SVGraph_Attach().Document.parentWindow.eval("var " ID " = plot.NewGroup(""" ID """);")
	return ID
}

SVGraph_LinePlot(FunX, FunY, Colour := "#999", Resolution := 0, Axis := "x", Optimize := True){
	Axis := InStr(Axis, "[") ? Axis : """" Axis """"
	SVGraph_Attach().Document.parentWindow.eval("plot.LinePlot(""" FunX """, """ FunY """,""" Colour """," Resolution "," Axis "," Optimize ");")
}

SVGraph_ScatterPlot(LstX, LstY, Colour := "#999", Size := 4, Opacity := 1, ScaleAxes := False, Group := False){
	Group := Group ? Group : "undefined"
	StrX := "[", StrY := "["
	loop % (LstX.Length() < LstY.Length() ? LstX.Length() : LstY.Length()) {
		StrX .= LstX[A_Index] ","
		StrY .= LstY[A_Index] ","
	}
	StrX .= "]", StrY .= "]"
	SVGraph_Attach().Document.parentWindow.eval("plot.ScatterPlot(""" StrX """,""" StrY """,""" Colour """,""" Size """," Opacity "," ScaleAxes "," Group ");")
}

SVGraph_RemovePath(index := ""){
	SVGraph_Attach().Document.parentWindow.eval("plot.RemovePath(" __IsDefinedNum(index) ");")
}

SVGraph_SaveSVG(Filename){
	Critical
	SVG := FileOpen(Filename, "w")
	SVG.Write(SVGraph_FormatXML(SVGraph_Attach().Document.getElementById("svg").outerHTML))
	SVG.Close()
}

SVGraph_FormatXML(XML){
	SvgLst := StrSplit(RegExReplace(XML, "(`r|`n|`t)*"), "<")
	SvgLst.Delete(1)
	XML := ""
	for index, str in SvgLst {
		newLn := True
		str := "<" str
		RegExMatch(str, "<.*?>", tag)
		
		if(InStr(tag, "</")) {
			tab := SubStr(tab, 2)
			if(preTag = StrReplace(tag, "/")){
				newLn := False
			}
		}
		
		XML .= (newLn ? "`n" tab : "") str
		
		if((!InStr(tag, "/>") && !InStr(tag, "</"))) {
			tab .= "`t"
			if(pos := InStr(tag, " ")){
				tag := SubStr(tag, 1, pos - 1) ">"
			}
			preTag := tag
		} else {
			preTag := ""
		}
	}
	return SubStr(XML, 2)
}

SVGraph_MiniFormatXML(XML){
	SvgLst := StrSplit(RegExReplace(XML, "(`r|`n|`t)*"), "<")
	SvgLst.Delete(1)
	XML := "", opacity := True, bool := False
	for index, str in SvgLst {
		newLn := True
		str := "<" str
		RegExMatch(str, "<.*?>", tag)
		
		if(InStr(tag, "opacity=""0""") && !InStr(tag, "/>")){
			opacity := False
			if(pos := InStr(tag, " ")){
				opacityTag := SubStr(tag, 1, pos - 1) ">"
			}
		}
		
		if(InStr(tag, "</")) {
			tab := SubStr(tab, 2)
			if(preTag = StrReplace(tag, "/")){
				newLn := False
			}
		}
		
		XML .= (opacity && !InStr(str, "opacity=""0""") ? (newLn ? "`n" tab : "") str : "")
		
		if(!opacity && InStr(tag, "</") && opacityTag = StrReplace(tag, "/")) {
			MsgBox, % tag "`n" preTag
			opacity := True
		}
		
		if((!InStr(tag, "/>") && !InStr(tag, "</"))) {
			tab .= "`t"
			if(pos := InStr(tag, " ")){
				tag := SubStr(tag, 1, pos - 1) ">"
			}
			preTag := tag
		} else {
			preTag := ""
		}
	}
	return SubStr(XML, 2)
}

__IsNum(Num){
	if Num is Number
		return 1
	return 0
}

__IsDefined(val){
	if(val = "" || val = """""")
		return "undefined"
	return val
}

__IsDefinedNum(Num){
	if Num is Number
		return Num
	return "undefined"
}

