//
//  LibraryTableViewController.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 29/10/25.
//

import UIKit

class LibraryTableViewController: UITableViewController {
    
    var presenter: LibraryPresenter?
    
    // MARK: - Data
    private var books: [Book] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.fetchAllBooks()
        setupUI()
    }
    
    func setupUI() {
        title = "Library"
        tableView.backgroundColor = .systemBackground
        tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: "LibraryCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath) as? LibraryTableViewCell else {
            return UITableViewCell()
        }
        let book = books[indexPath.row]
        cell.configure(with: book)
        return cell
    }
    
    // MARK: - Optional: Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = books[indexPath.row]
        print("Selected book: \(book.title)")
    }
}

extension LibraryTableViewController: LibraryPresenterDelegate {
    func showLoading(_ isLoading: Bool) {
        print("Loading: \(isLoading)")
    }
    
    func showError(_ message: String) {
        print("Error: \(message)")
    }
    
    func showBooks(_ books: [Book]) {
        self.books = books
        print(books)
        tableView.reloadData()
    }
}
