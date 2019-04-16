/* This header file describes the subset of the curses interface being used by this program.
 *
 * This file is then used to generate an SML interface using ml-nlffigen. For some reason
 * ml-nlffigen runs into errors when run on the *official* ncurses.h, so this file is a much
 * simpler version only describing the end-user interface to the dynamic library needed by the program.
 */

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
