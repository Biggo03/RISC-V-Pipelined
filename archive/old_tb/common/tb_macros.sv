`define CHECK(cond, msg, arg1=, arg2=) \
    assert(cond) else begin \
        $error(msg, arg1, arg2); \
        error_cnt++; \
    end