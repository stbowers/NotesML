/* This header file describes the subset of the curses interface being used by this program.
 *
 * This file is then used to generate an SML interface using ml-nlffigen. For some reason
 * ml-nlffigen runs into errors when run on the *official* ncurses.h, so this file is a much
 * simpler version only describing the end-user interface to the dynamic library needed by the program.
 */

extern int COLS;
extern int LINES;

typedef char bool;
typedef void WINDOW; // WINDOW is always used as a pointer, so a void pointer works here
typedef short chtype;

/* Control functions
 */
WINDOW *initscr();
int endwin();

int refresh();

int cbreak();
int nocbreak();
int echo();
int noecho();
int halfdelay(int tenths);
int intrflush(WINDOW *win, bool bf);
int keypad(WINDOW *win, bool bf);
int meta(WINDOW *win, bool bf);
int nodelay(WINDOW *win, bool bf);
int raw();
int noraw();
void noqiflush();
void qiflush();
int notimeout(WINDOW *win, bool bf);
void timeout(int delay);
void wtimeout(WINDOW *win, int delay);
int typeahead(int fd);

int curs_set(int visibility);

int start_color();
bool has_colors();
bool can_change_color();
int init_pair(short pair, short f, short b);
int init_color(short color, short r, short g, short b);

int getattrs(WINDOW *win);
int getbegx(WINDOW *win);
int getbegy(WINDOW *win);
int getcurx(WINDOW *win);
int getcury(WINDOW *win);
int getmaxx(WINDOW *win);
int getmaxy(WINDOW *win);
int getparx(WINDOW *win);
int getpary(WINDOW *win);

int erase();
int werase(WINDOW *win);
int clear();
int wclear(WINDOW* win);
int clrtobot();
int wclrtobot(WINDOW *win);
int clrtoeol();
int wclrtoeol(WINDOW *win);

/* Output functions (NLFFI Does not support variadic arguments, so only format string is used)
 */
int addch(const chtype ch);

int printw(const char *fmt);
int wprintw(WINDOW *win, const char *fmt);
int mvprintw(int y, int x, const char *fmt);
int mvwprintw(WINDOW *win, int y, int x, const char *fmt);

/* Input functions
 */
int getch();
