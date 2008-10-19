require "fileutils"


namespace :doc do

  desc "Generate HTML, LaTeX and man(3) documentation from codebase."
  task :doxygen => "doc:doxygen:generate"

  desc "Generate opcode docs."
  task :opcode => "doc:opcode:generate"

  desc "Delete all generated documentation"
  task :clean => %w[doc:doxygen:clean doc:opcode:clean]


  namespace :doxygen do

    directory "vm/doc/generated"

      desc "Generate HTML, LaTeX and man(3) documentation from codebase."
      task :generate => %w[vm/doc/generated vm/doc/doxygen.conf] do
        sh "doxygen vm/doc/doxygen.conf"
      end

      desc "Delete all documentation generated by Doxygen"
      task :clean do
        if File.directory? "vm/doc/generated"
          FileUtils.rm_r "vm/doc/generated", :secure => true, :verbose => $verbose
        end
      end

  end

  namespace :opcode do

    desc "Generate opcode documentation HTML"
    task :generate => "vm/doc/opcode/toc.html"

    directory "vm/doc/opcode"

    file 'vm/doc/opcode/toc.html' => %w[vm/doc/opcode shotgun/lib/instructions.rb] do
      rbx 'vm/doc/opcode/gen_op_code_html.rb'
    end

    rule '.html' => %w[.txt vm/doc/opcode/rdoc.rb] do |t|
      rbx 'vm/doc/opcode/rdoc.rb', t.source, t.name
    end

    task :html => %w[
      build
      vm/doc/opcode/toc.html
      vm/doc/opcode/concurrency.html
      vm/doc/opcode/intro.html
      vm/doc/opcode/method_dispatch.html
      vm/doc/opcode/rbc_files.html
      vm/doc/opcode/rubinius_vs_mri.html
      vm/doc/opcode/shotgun.html
      vm/doc/opcode/toc.html
      vm/doc/opcode/vm_interfaces.html
    ]

    desc "Remove all generated opcode docs"
    task :clean do
      Dir.glob('vm/doc/opcode/**/*.html').each do |html|
        rm_f html unless html =~ /\/?index.html$/
      end
    end

  end

end

