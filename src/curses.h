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
typedef chtype attr_t;

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
int init_pair(int pair, int f, int b);
int init_color(int color, int r, int g, int b);

int use_default_colors();
int assume_default_colors(int fg, int bg);

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

int attr_get(attr_t *attrs, short *pair, void *opts);
int wattr_get(WINDOW *win, attr_t *attrs, short *pair, void *opts);
int attr_set(attr_t attrs, short pair, void *opts);
int wattr_set(WINDOW *win, attr_t attrs, short pair, void *opts);

int attr_off(attr_t attrs, void *opts);
int wattr_off(WINDOW *win, attr_t attrs, void *opts);
int attr_on(attr_t attrs, void *opts);
int wattr_on(WINDOW *win, attr_t attrs, void *opts);

int attroff(int attrs);
int wattroff(WINDOW *win, int attrs);
int attron(int attrs);
int wattron(WINDOW *win, int attrs);
int attrset(int attrs);
int wattrset(WINDOW *win, int attrs);

int chgat(int n, attr_t attr, short pair, const void *opts);
int wchgat(WINDOW *win,
int n, attr_t attr, short pair, const void *opts);
int mvchgat(int y, int x,
int n, attr_t attr, short pair, const void *opts);
int mvwchgat(WINDOW *win, int y, int x,
int n, attr_t attr, short pair, const void *opts);

int color_set(short pair, void* opts);
int wcolor_set(WINDOW *win, short pair, void* opts);

int standend(void);
int wstandend(WINDOW *win);
int standout(void);
int wstandout(WINDOW *win);

int COLOR_PAIR(int);

/* Output functions (NLFFI Does not support variadic arguments, so only format string is used)
 */
int addch(const chtype ch);

int addstr(const char *str);
int addnstr(const char *str, int n);
int waddstr(WINDOW *win, const char *str);
int waddnstr(WINDOW *win, const char *str, int n);
int mvaddstr(int y, int x, const char *str);
int mvaddnstr(int y, int x, const char *str, int n);
int mvwaddstr(WINDOW *win, int y, int x, const char *str);
int mvwaddnstr(WINDOW *win, int y, int x, const char *str, int n);

/* Input functions
 */
int getch();
