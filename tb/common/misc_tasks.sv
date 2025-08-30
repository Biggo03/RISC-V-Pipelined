task automatic dump_setup;
  begin
    `ifdef DUMP_PATH
      $display("Dumping VCD to: %s", `DUMP_PATH);
      $dumpfile(`DUMP_PATH);
    `else
      $display("Unable to dump VCD\nPlease supply a DUMP_PATH");
    `endif
    $dumpvars;
  end
endtask

