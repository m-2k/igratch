-define(ROOT, code:priv_dir(web)).

-record(struct, {lst=[]}).
-record(product_figure,{?ELEMENT_BASE(product_ui), product}).
-record(product_row,   {?ELEMENT_BASE(product_ui), product}).
-record(product_line,  {?ELEMENT_BASE(product_ui), product, meta, controls}).
-record(product_hero,  {?ELEMENT_BASE(product_ui), product}).
-record(product_entry, {?ELEMENT_BASE(product_ui), entry, mode=brief, prod_id, category}).
-record(entry_media,   {?ELEMENT_BASE(product_ui), media, fid, cid, mode}).
-record(entry_comment, {?ELEMENT_BASE(product_ui), comment}).

