# Preview all emails at http://localhost:3000/rails/mailers/host_proposal_mailer
class HostProposalMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/host_proposal_mailer/notify_admin
  def notify_admin
    HostProposalMailer.notify_admin
  end
end
