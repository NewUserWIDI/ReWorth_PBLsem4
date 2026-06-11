<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_role('dlh');

$currentUser = current_user();

render_layout('Profil Akun', function () use ($currentUser): void {
?>

<style>

.profile-page{
    width:100%;
    padding:24px 32px 64px;
    box-sizing:border-box;
}

.profile-hero-card,
.account-card{
    width:100%;
    background:#FFFFFF;
    border:1px solid #ECEEF1;
    border-radius:28px;
    box-shadow:0 8px 32px rgba(0,0,0,.03);
    box-sizing:border-box;
}

.profile-hero-card{
    padding:40px;
    display:flex;
    align-items:flex-start;
    gap:48px;
    margin-bottom:24px;
}

.profile-avatar{
    width:180px;
    height:180px;
    border-radius:50%;
    background:#2E7D32;
    color:#FFFFFF;
    font-size:64px;
    font-weight:700;
    display:flex;
    align-items:center;
    justify-content:center;
    flex-shrink:0;
}

.profile-main-info{
    flex:1;
    min-width:0;
}

.profile-top{
    display:flex;
    justify-content:space-between;
    align-items:flex-start;
    margin-bottom:32px;
}

.profile-top h2{
    margin:0;
    font-size:48px;
    font-weight:700;
    line-height:1.2;
    color:#111827;
}

.status-badge{
    display:inline-flex;
    align-items:center;
    background:#ECFDF3;
    color:#15803D;
    padding:8px 16px;
    border-radius:999px;
    margin-top:14px;
    font-size:14px;
    font-weight:600;
}

.btn-edit{
    height:48px;
    padding:0 22px;
    border:1px solid #D0D5DD;
    border-radius:14px;
    background:#FFFFFF;
    font-weight:600;
    cursor:pointer;
}

.profile-grid{
    display:grid;
    grid-template-columns:repeat(4,minmax(0,1fr));
    gap:24px;
}

.profile-item{
    display:flex;
    flex-direction:column;
}

.profile-item span{
    font-size:13px;
    color:#98A2B3;
    margin-bottom:6px;
}

.profile-item strong{
    font-size:17px;
    font-weight:600;
    color:#111827;
    word-break:break-word;
}

.text-success{
    color:#15803D;
}

.account-card{
    padding:32px;
}

.account-card h3{
    margin:0 0 24px;
    font-size:24px;
    font-weight:700;
    color:#111827;
}

.info-row{
    min-height:72px;
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:24px;
    border-bottom:1px solid #ECEEF1;
}

.info-row:last-child{
    border-bottom:none;
}

.info-row span{
    font-size:15px;
    color:#667085;
}

.info-row strong{
    font-size:16px;
    font-weight:600;
    color:#111827;
    text-align:right;
    word-break:break-word;
}

@media (max-width:992px){

    .profile-hero-card{
        flex-direction:column;
    }

    .profile-grid{
        grid-template-columns:repeat(2,1fr);
    }

    .profile-top{
        flex-direction:column;
        gap:20px;
    }

}

@media (max-width:640px){

    .profile-page{
        padding:16px;
    }

    .profile-grid{
        grid-template-columns:1fr;
    }

    .profile-top h2{
        font-size:32px;
    }

    .info-row{
        flex-direction:column;
        align-items:flex-start;
        padding:12px 0;
    }

    .info-row strong{
        text-align:left;
    }

}

</style>

<section class="profile-page">

    <div class="profile-hero-card">

        <div class="profile-avatar">
            <?= strtoupper(substr($currentUser['nama_lengkap'] ?? 'P', 0, 1)) ?>
        </div>

        <div class="profile-main-info">

            <div class="profile-top">

                <div>
                    <h2><?= e($currentUser['nama_lengkap'] ?? 'Petugas DLH') ?></h2>

                    <div class="status-badge">
                        Akun Aktif
                    </div>
                </div>

                <button class="btn-edit" type="button">
                    Edit Profil
                </button>

            </div>

            <div class="profile-grid">

                <div class="profile-item">
                    <span>Email</span>
                    <strong><?= e($currentUser['email'] ?? '-') ?></strong>
                </div>

                <div class="profile-item">
                    <span>Username</span>
                    <strong><?= e($currentUser['username'] ?? '-') ?></strong>
                </div>

                <div class="profile-item">
                    <span>Role</span>
                    <strong><?= strtoupper(e($currentUser['role'] ?? '-')) ?></strong>
                </div>

                <div class="profile-item">
                    <span>Status</span>
                    <strong class="text-success">Aktif</strong>
                </div>

            </div>

        </div>

    </div>

    <div class="account-card">

        <h3>Informasi Akun</h3>

        <div class="info-row">
            <span>Nama Lengkap</span>
            <strong><?= e($currentUser['nama_lengkap'] ?? '-') ?></strong>
        </div>

        <div class="info-row">
            <span>Email</span>
            <strong><?= e($currentUser['email'] ?? '-') ?></strong>
        </div>

        <div class="info-row">
            <span>Username</span>
            <strong><?= e($currentUser['username'] ?? '-') ?></strong>
        </div>

        <div class="info-row">
            <span>Role</span>
            <strong><?= strtoupper(e($currentUser['role'] ?? '-')) ?></strong>
        </div>

        <div class="info-row">
            <span>Status Akun</span>
            <strong class="text-success">Aktif</strong>
        </div>

    </div>

</section>

<?php
});
?>