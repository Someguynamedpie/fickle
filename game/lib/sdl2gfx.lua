local ffi = require 'ffi'

ffi.cdef[[
typedef struct _FILE FILE;
]]

ffi.cdef[[


/* Pixel */

int pixelColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Uint32 color);
int pixelRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Horizontal line */

int hlineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 x2, Sint16 y, Uint32 color);
int hlineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 x2, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Vertical line */

int vlineColor(SDL_Renderer * renderer, Sint16 x, Sint16 y1, Sint16 y2, Uint32 color);
int vlineRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y1, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Rectangle */

int rectangleColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
int rectangleRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
	Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Rounded-Corner Rectangle */

int roundedRectangleColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 rad, Uint32 color);
int roundedRectangleRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
	Sint16 x2, Sint16 y2, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled rectangle (Box) */

int boxColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
int boxRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2,
	Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Rounded-Corner Filled rectangle (Box) */

int roundedBoxColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 rad, Uint32 color);
int roundedBoxRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2,
	Sint16 y2, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Line */

int lineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
int lineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
	Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* AA Line */

int aalineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
int aalineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
	Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Thick Line */
int thickLineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, 
	Uint8 width, Uint32 color);
int thickLineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, 
	Uint8 width, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Circle */

int circleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Uint32 color);
int circleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Arc */

int arcColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Sint16 start, Sint16 end, Uint32 color);
int arcRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Sint16 start, Sint16 end, 
	Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* AA Circle */

int aacircleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Uint32 color);
int aacircleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
	Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled Circle */

int filledCircleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 r, Uint32 color);
int filledCircleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
	Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Ellipse */

int ellipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
int ellipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
	Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* AA Ellipse */

int aaellipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
int aaellipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
	Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled Ellipse */

int filledEllipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
int filledEllipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
	Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Pie */

int pieColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
	Sint16 start, Sint16 end, Uint32 color);
int pieRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
	Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled Pie */

int filledPieColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
	Sint16 start, Sint16 end, Uint32 color);
int filledPieRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
	Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Trigon */

int trigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);
int trigonRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
	Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* AA-Trigon */

int aatrigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);
int aatrigonRGBA(SDL_Renderer * renderer,  Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
	Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled Trigon */

int filledTrigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);
int filledTrigonRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
	Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Polygon */

int polygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
int polygonRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
	int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* AA-Polygon */

int aapolygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
int aapolygonRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
	int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Filled Polygon */

int filledPolygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
int filledPolygonRGBA(SDL_Renderer * renderer, const Sint16 * vx,
	const Sint16 * vy, int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/* Textured Polygon */

int texturedPolygon(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, SDL_Surface * texture,int texture_dx,int texture_dy);

/* Bezier */

int bezierColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, int s, Uint32 color);
int bezierRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
	int n, int s, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
SDL_Surface *rotozoomSurface(SDL_Surface * src, double angle, double zoom, int smooth);

SDL_Surface *rotozoomSurfaceXY
	(SDL_Surface * src, double angle, double zoomx, double zoomy, int smooth);


void rotozoomSurfaceSize(int width, int height, double angle, double zoom, int *dstwidth,
	int *dstheight);

void rotozoomSurfaceSizeXY
	(int width, int height, double angle, double zoomx, double zoomy, 
	int *dstwidth, int *dstheight);

/* 

Zooming functions

*/

SDL_Surface *zoomSurface(SDL_Surface * src, double zoomx, double zoomy, int smooth);

void zoomSurfaceSize(int width, int height, double zoomx, double zoomy, int *dstwidth, int *dstheight);

/* 

Shrinking functions

*/     

SDL_Surface *shrinkSurface(SDL_Surface * src, int factorx, int factory);

/* 

Specialized rotation functions

*/

SDL_Surface* rotateSurface90Degrees(SDL_Surface* src, int numClockwiseTurns);
]]
local module = ffi.load'SDL2_gfx'
local gfx = setmetatable( {}, {__index = function(_, k) return module[k] end} )



return gfx
