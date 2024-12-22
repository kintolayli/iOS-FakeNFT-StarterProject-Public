import UIKit

final class CartRemovingViewController: UIViewController {
    var item: CartItem? {
        didSet {
            nftImageView.kf.setImage(with: URL(string: item?.imageUrl ?? ""))
        }
    }
    
    private let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    private let deleteConfirmationView = UIView()
    private let nftImageView = UIImageView()
    private let deleteConfirmationLabel = UILabel()
    
    private let buttonsStackView = UIStackView()
    private let deleteButton = UIButton()
    private let returnButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBluredView()
        setupDeleteConfirmationView()
        setupNftImageView()
        setupDeleteConfirmationLabel()
        setupButtonsStackView()

    }
    
    private func setupBluredView() {
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurredView)
        
        NSLayoutConstraint.activate([
            blurredView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurredView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupDeleteConfirmationView() {
        setupNftImageView()
        setupDeleteConfirmationLabel()
        setupButtonsStackView()
        
        deleteConfirmationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(deleteConfirmationView)
        
        NSLayoutConstraint.activate([
            deleteConfirmationView.widthAnchor.constraint(equalToConstant: 262),
            deleteConfirmationView.heightAnchor.constraint(equalToConstant: 220),
            deleteConfirmationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteConfirmationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupNftImageView() {
        nftImageView.kf.indicatorType = .activity
        nftImageView.layer.cornerRadius = 12
        nftImageView.clipsToBounds = true
        
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteConfirmationView.addSubview(nftImageView)
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            nftImageView.centerXAnchor.constraint(equalTo: deleteConfirmationView.centerXAnchor),
            nftImageView.topAnchor.constraint(equalTo: deleteConfirmationView.topAnchor)
        ])
    }
    
    private func setupDeleteConfirmationLabel() {
        deleteConfirmationLabel.text = "Вы уверены, что хотите удалить объект из корзины?"
        deleteConfirmationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        deleteConfirmationLabel.textColor = UIColor(resource: .ypBlack)
        deleteConfirmationLabel.numberOfLines = 2
        deleteConfirmationLabel.textAlignment = .center
        
        deleteConfirmationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deleteConfirmationView.addSubview(deleteConfirmationLabel)
        
        NSLayoutConstraint.activate([
            deleteConfirmationLabel.widthAnchor.constraint(equalToConstant: 180),
            deleteConfirmationLabel.heightAnchor.constraint(equalToConstant: 36),
            deleteConfirmationLabel.centerXAnchor.constraint(equalTo: deleteConfirmationView.centerXAnchor),
            deleteConfirmationLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 12)
        ])
    }
    
    private func setupButtonsStackView() {
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(UIColor(resource: .yRed), for: .normal)
        deleteButton.backgroundColor = UIColor(resource: .ypBlack)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        deleteButton.layer.cornerRadius = 16
        deleteButton.clipsToBounds = true
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        
        returnButton.setTitle("Вернутся", for: .normal)
        returnButton.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        returnButton.backgroundColor = UIColor(resource: .ypBlack)
        returnButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        returnButton.layer.cornerRadius = 16
        returnButton.clipsToBounds = true
        returnButton.addTarget(self, action: #selector(didTapReturnButton), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStackView.addArrangedSubview(deleteButton)
        buttonsStackView.addArrangedSubview(returnButton)
        deleteConfirmationView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44),
            buttonsStackView.leadingAnchor.constraint(equalTo: deleteConfirmationView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: deleteConfirmationView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: deleteConfirmationLabel.bottomAnchor, constant: 20),
            buttonsStackView.bottomAnchor.constraint(equalTo: deleteConfirmationView.bottomAnchor)
        ])
    }
    
    @objc
    private func didTapDeleteButton() {
    }
    
    @objc
    private func didTapReturnButton() {
    }
}
