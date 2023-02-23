#include <nterm.h>
#include <stdarg.h>
#include <unistd.h>
#include <SDL.h>

char handle_key(SDL_Event *ev);
void clear_display(void);

static void sh_printf(const char *format, ...) {
  static char buf[256] = {};
  va_list ap;
  va_start(ap, format);
  int len = vsnprintf(buf, 256, format, ap);
  va_end(ap);
  term->write(buf, len);
}

static void sh_banner() {
  sh_printf("Built-in Shell in NTerm (NJU Terminal)\n\n");
}

static void sh_prompt() {
  sh_printf("sh> ");
}

static void sh_handle_cmd(const char *cmd, char *envp[]) {
  if(cmd) 
  {
    const char *blank_char = " \t\n";
    size_t start = strspn(cmd, blank_char);
    size_t end = strcspn(cmd + start, blank_char);
    char fname[128];
    strncpy(fname, cmd + start, end - start);// delete \n
    fname[end - start] = '\0';
    printf("file: %s\n", fname);
    //clear_display();
    const char *exec_argv[3] = {fname, NULL, NULL};
    #ifndef __ISA_NATIVE__
    execvp(fname, (char**)exec_argv);
    #else
    execve(fname, (char *const *)exec_argv, (char *const *)envp);
    #endif
  }
}

void builtin_sh_run(char *envp[]) {
  sh_banner();
  sh_prompt();
	setenv("PATH","/bin",0);

  while (1) {
    SDL_Event ev;
    if (SDL_PollEvent(&ev)) {
      if (ev.type == SDL_KEYUP || ev.type == SDL_KEYDOWN) {
        const char *res = term->keypress(handle_key(&ev));
        if (res) {
          sh_handle_cmd(res, envp);
          sh_prompt();
        }
      }
    }
    refresh_terminal();
  }
}
