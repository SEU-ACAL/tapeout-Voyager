#ifndef PAGE_H
#define PAGE_H

void page_init(void);
void *page_alloc(int npages);
void page_free(void *p);

#endif /* PAGE_H */
