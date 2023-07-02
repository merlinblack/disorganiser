-- Global definition file for Lua language server.
---@meta

---C++ defined Classes

---@class Application
---@field ticks integer Number of ticks since application started.
---@field shouldRestart boolean Should the application restart.
---@field shouldStop boolean Should the application stop and exit.
---@field showCursor boolean Determins if the mouse cursor is visible.
---@field renderList RenderList Main application render list
---@field overlay RenderList Secondary application render list, shown on top
---@field textInputMode boolean Is SDL's textInputMode enabled or not.
---@field emptyTexture Texture A blank tiny texture for use as a placeholder.
---@field width integer Application window width in pixels.
---@field height integer Application window height in pixels.
---@field onRaspberry boolean Is the application running on my raspberry pi.
---@field version string Version string

---@class Atlas
Atlas = {}

---@class Color
---@field r integer Red 0 - 255
---@field g integer Green 0 - 255
---@field b integer Blue 0 - 255
---@field a integer Alpha 0 - 255
---@overload fun(hex:string):Color
---@overload fun(red:integer,green:integer,blue:integer,alpha:integer):Color
Color = {}
---Make a deep copy of the color
---@return Color deepcopy
function Color:clone() end

---@class EditString 
---@overload fun():EditString
EditString = {}
---Retrieve the edited string
---@return string
function EditString:getString() end
---Set the string to be edited
---@param string string
function EditString:setString(string) end
---Move the cursor to the start of the strig
function EditString:gotoStart() end
---Move the cursor to the end of the string
function EditString:gotoEnd() end
---Move the cursor back one character
function EditString:back() end
---Move the cursor forward one character
function EditString:forward() end
---Move the cursor back one word
function EditString:backWord() end
---Move the cursor forward one word
function EditString:forwardWord() end
---Retrieve the cursor position
---@return integer
function EditString:index() end
---Set the string to be edited to ""
function EditString:clear() end
---Insert a character at the cursor position
---@param characters string
function EditString:insert(characters) end
---Remove the character at the cursor position
function EditString:erase() end

---@class Font 
---@field lineHeight integer Height in pixels of the font
---@field cacheStats table
---@overload fun(path:string, pointSize:integer):Font
Font = {}
---Return rendered text size for Font
---@return integer width, integer height
---@param text string 
function Font:sizeText(text) end

---@class LineList : Renderable
---@field color Color
---@overload fun(color?:Color):LineList
LineList = {}
---Add a point to the list
---@param x integer
---@param y integer
function LineList:addPoint(x, y) end

---@class ProcessReader 
---@overload fun():ProcessReader
ProcessReader = {}
---Open the process for reading
---@return boolean Success
function ProcessReader:open() end
---Close the process
function ProcessReader:close() end
---Add a command line argument
---@param argument string
function ProcessReader:add(argument) end
---Set the executable file path
---@param executable string
function ProcessReader:set(executable) end
---Clear all arguments
function ProcessReader:clear() end
---Read from process
---@return boolean moreToCome, string data
function ProcessReader:read() end

---@class Rectangle : Renderable
---@field texture Texture
---@overload fun(texture:Texture, x:number, y:number): Rectangle
---@overload fun(texture:Texture, dest:table, source?:table): Rectangle
---@overload fun(color:Color, fill:boolean, dest:table): Rectangle
Rectangle = {}
---@param rect table Set destination rectangle {x,y,w,h}
function Rectangle:setDest(rect) end
---@param rect table Set source rectangle {x,y,w,h}
function Rectangle:setSource(rect) end
---@param rect table Set clip rectangle {x,y,w,h}
function Rectangle:setClip(rect) end
---@param color Color
function Rectangle:setColor(color) end
---@param enable boolean Set if rectangle is filled with color
function Rectangle:setFill(enable) end

---Base class for all classes that have a 'render' function can be put into a render list.
---@class Renderable 
Renderable = {}

---@class Renderer 
Renderer = {}

---@class RenderList : Renderable
---@overload fun(): RenderList
RenderList = {}
---Add a renderable element to the end of a render list
---@param element Renderable
function RenderList:add(element) end
---Add a renderable element to a render list and then sort
---@param element Renderable
function RenderList:insert(element) end
---Remove a renderable element from a render list
---@param element Renderable
function RenderList:remove(element) end
---Set wheather a render list should render on next 'turn'
---@param shouldRender? boolean Defaults to true
function RenderList:shouldRender(shouldRender) end
---Remove all elements from a render list
function RenderList:clear() end
---Sort render list by renderable's order
function RenderList:sort() end

---@class Texture 
---@field width number
---@field height number
---@overload fun(path:string):Texture
---@overload fun(font:Font, text:string, color:Color):Texture
Texture = {}

---C++ defined instances and functions

---Application instance
---@type Application
app = {}

---Add a task to the task list.
---Task will be removed when the function ends.
---@return string name Name of the task
---@param taskFunc function Lua function to run as a task
---@param name? string Optional name for the task
function addTask(taskFunc, name) end

---Get a list of all current tasks
---@return table list Table of strings
function getTasks() end

---Get the name of the currently running task
---@return string name
function getCurrentTaskName() end

---Cause a task that is waiting to return from wait() on next 'turn'
---@param name string Name of the task to wake.
function wakeTask(name) end

---Cause a task that is waiting to be asked to terminate on next 'turn'
---@param name string Name of the task to kill.
function killTask(name) end

-- Lua defined classes
---@class Class 
---@field __type string Name of the class.

---@class Widget : Class
---@field updateAction function If set, action to take on update.
Widget = {}

---@class Button : Widget 
Button = {}

---@class Screen : Widget
Screen = {}

---@class HoverText : Widget
HoverText = {}

---@class ConfirmDialog : Screen
ConfirmDialog = {}
---@class Console : Widget
Console = {}
---@class Docker : Screen
Docker = {}
---@class History : Class
History = {}
---@class MainScreen : Screen
MainScreen = {}
---@class MainScreen2 : Screen
MainScreen2 = {}
---@class Run : Class
Run = {}
---@class ScreenSaver : Screen
ScreenSaver = {}
---@class Suspend : Screen
Suspend = {}
---@class SystemUpdate : Screen
SystemUpdate = {}
---@class TextLog : Class
---@overload fun(renderList:RenderList, x:integer, y:integer, background:Color, color: Color, font:Font, width:integer, height:integer):TextLog
TextLog = {}
---@class Unlock : Screen
Unlock = {}
---@class WeatherGraphs : Screen
WeatherGraphs = {}
---@class WeatherTrends : Screen
WeatherTrends = {}

-- Globals defined in .config/disorganiser/config.lua
---@table
imap = {}
---@table
ipaddr = {}
---@table
secret = {}

-- Optional globals set from console.

---@boolean Keep screensave from starting.
caffine = false
---@boolean Should hover text show?
showHoverText = true
---@integer Number of hours to show on weather grahps
hours = 24