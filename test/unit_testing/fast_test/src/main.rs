// ==========================================
// * Haxe UCPP Target "Fast Test"
//
// Runs `haxe Test.hxml test=TestName` for every test.
// Does it with threads, so happens super fast.
// ==========================================

use std::env::{self, current_dir};
use std::fs;
use std::io::{stdout, Write};
use std::path::PathBuf;
use std::process::Command;
use std::thread;
use std::sync::{Arc, Mutex};
use std::sync::atomic::{AtomicUsize, Ordering};

// Print updated progress for completed tests
fn update_progress(progress: Option<usize>, total: &usize) {
    if progress.is_some() {
        let result = format!("\r{:?} / {:?} tests complete... 🧠", progress.unwrap(), total);
        print!("{}", result);
        stdout().flush().unwrap();
    }
}

fn main() -> std::io::Result<()> {
    // Store threads and test names
    let mut threads = vec!();
    let mut test_names = vec!();

    // Get base of repository.
    let repo_path = {
        // Get a list of the arguments
        let args: Vec<String> = env::args().collect();
        if args.len() > 1 {
            // Generate PathBuf from first argument
            PathBuf::from(args[1].clone())
        } else {
            // Only works if executed in test/unit_testing/fast_test
            // Used when no argument is provided
            let mut dir = current_dir()?;
            for _ in 0..3 { dir.pop(); }
            dir
        }
    };

    // Get list of tests.
    {
        let mut dir = repo_path.clone();

        // Move to test/unit_testing/fast_test
        dir.push("test");
        dir.push("unit_testing");
        dir.push("tests");

        // Iterate through all folders and store their names
        for file in fs::read_dir(dir)? {
            let dir = file?;
            test_names.push(dir.path());
        }
    }

    // Count the number of tests completed and failured
    let complete_count = Arc::new(AtomicUsize::new(0));
    let fail_count = Arc::new(AtomicUsize::new(0));

    // Number of tests
    let test_len = test_names.len();

    // Store the stderr here
    let error_str: Arc<Mutex<String>> = Arc::new(Mutex::new("".to_string()));

    // Print initial tests complete text
    update_progress(Some(0), &test_len);

    // Iterate through each test and create new thread.
    for test in test_names {
        // Make copy of base repository path.
        let rpath = repo_path.as_os_str().to_str().unwrap().to_string();

        // Clone all Arcs to move into thread
        let fc = fail_count.clone();
        let cc = complete_count.clone();
        let es = error_str.clone();

        // Create thread.
        let t = thread::spawn(move || {
            // Make test=TestName argument
            let test_arg = "test=".to_owned() + test.file_name().unwrap().to_str().unwrap();
            
            // Run command `haxe Test.hxml test=TestName`
            let output = Command::new("haxe")
                .args(["Test.hxml", &test_arg])
                .current_dir(&rpath)
                .output()
                .unwrap();

            // Increment test count and print it
            update_progress(Some(cc.fetch_add(1, Ordering::SeqCst) + 1), &test_len);

            // Print result if did not return with exit code 0.
            if !output.status.success() {
                let err = String::from_utf8(output.stderr).expect("Get string from stderr failed.");
                if !err.is_empty() {
                    let mut data = es.lock().unwrap();
                    *data += &err;
                }
                fc.fetch_add(1, Ordering::SeqCst);
            }
        });

        // Add thread to vec
        threads.push(t);
    }

    // Wait for all threads to complete
    for t in threads {
        t.join().unwrap();
    }

    // Move to new line.
    println!();

    // Print all error output
    println!("{}", error_str.lock().unwrap());

    // Print number of tests passed
    let tests_passed = test_len - fail_count.load(Ordering::SeqCst);
    println!("{:?} / {:?} tests passed! 🚀", tests_passed, test_len);

    // okay
    Ok(())
}
