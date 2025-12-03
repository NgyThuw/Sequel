CREATE DATABASE QLCHK
USE QLCHK
--1/ (1,0)
--TẠO BẢNG VÀ RÀNG BUỘC
CREATE TABLE SANBAY(
MASB VARCHAR(10) NOT NULL PRIMARY KEY,
TENSB NVARCHAR(100),
DIACHI NVARCHAR(100)
)
CREATE TABLE CHUYENBAY(
MACB VARCHAR(10) NOT NULL PRIMARY KEY,
MASB_DI VARCHAR(10),
MASB_DEN VARCHAR(10),
NGAYGIO NVARCHAR(50),
TONGCHO INT
)
CREATE TABLE HANHKHACH(
MAHK VARCHAR(10) NOT NULL PRIMARY KEY,
HOTEN NVARCHAR(100),
CMND NVARCHAR(20)
)
CREATE TABLE VE(
MAVE VARCHAR(10) NOT NULL PRIMARY KEY,
MAHK VARCHAR(10) NOT NULL,
MACB VARCHAR(10) NOT NULL,
LOAI NVARCHAR(50),
GIA INT,
CONSTRAINT FK_VE1 FOREIGN KEY(MAHK) REFERENCES HANHKHACH(MAHK),
CONSTRAINT FK_VE2 FOREIGN KEY(MACB) REFERENCES CHUYENBAY(MACB)
)
CREATE TABLE NHANVIEN(
MANV VARCHAR(10) NOT NULL PRIMARY KEY,
HOTEN NVARCHAR(100),
VITRI NVARCHAR(50),
SODIENTHOAI NVARCHAR(50)
)
--NHẬP DỮ LIỆU
INSERT INTO SANBAY (MASB, TENSB, DIACHI) VALUES
('SGN', N'Sân bay Quốc tế Tân Sơn Nhất', N'TP. Hồ Chí Minh'),
('HAN', N'Sân bay Quốc tế Nội Bài', N'Hà Nội'),
('DAD', N'Sân bay Quốc tế Đà Nẵng', N'Đà Nẵng'),
('CXR', N'Sân bay Quốc tế Cam Ranh', N'Khánh Hòa');
INSERT INTO CHUYENBAY (MACB, MASB_DI, MASB_DEN, NGAYGIO, TONGCHO) VALUES
('VN240', 'SGN', 'HAN', '2025-12-25 08:00', 180),
('VJ777', 'HAN', 'SGN', '2025-12-25 10:30', 200),
('QH101', 'DAD', 'SGN', '2025-12-26 14:00', 150),
('VN198', 'HAN', 'DAD', '2025-12-26 18:30', 120),
('VJ600', 'SGN', 'CXR', '2025-12-27 06:00', 180);
INSERT INTO HANHKHACH (MAHK, HOTEN, CMND) VALUES
('HK001', N'Nguyễn Văn Ánh', '001298765432'),
('HK002', N'Trần Thị Bình', '002345678901'),
('HK003', N'Lê Minh Thức', '003456789012'),
('HK004', N'Phạm Thu Diễm', '004567890123');
INSERT INTO VE (MAVE, MAHK, MACB, LOAI, GIA) VALUES
('V0001', 'HK001', 'VN240', N'Phổ thông', 1500000),
('V0002', 'HK002', 'VN240', N'Thương gia', 3500000),
('V0003', 'HK003', 'VJ777', N'Phổ thông', 1200000),
('V0004', 'HK001', 'QH101', N'Phổ thông', 1800000),
('V0005', 'HK004', 'VJ600', N'Phổ thông', 1000000);
INSERT INTO NHANVIEN (MANV, HOTEN, VITRI, SODIENTHOAI) VALUES
('NV001', N'Hoàng Thanh Nhã', N'Tiếp viên trưởng', '0901112222'),
('NV002', N'Đỗ Quốc Phú', N'Phi công', '0903334444'),
('NV003', N'Bùi Huyền Linh', N'Nhân viên mặt đất', '0905556666');

SELECT *FROM SANBAY
SELECT *FROM CHUYENBAY
SELECT *FROM HANHKHACH
SELECT *FROM VE
SELECT *FROM NHANVIEN
--2/ (2,0)
--a. Lệnh sao lưu toàn bộ cơ sở dữ liệu
ALTER DATABASE QLCHK
SET RECOVERY FULL
BACKUP DATABASE QLCHK
TO DISK ='E:\LuuDuLieuSinhVien\44_NguyenThiAnhThu_B13\39_NguyenThiAnhThu_KT2\full_backup_qlchk.bak'
with init;
--b. Giả sử csdl bị lỗi, viết lệnh phục hồi csdl từ file sao lưu trên
DROP DATABASE QLCHK
USE master
RESTORE DATABASE QLCHK
FROM DISK ='E:\LuuDuLieuSinhVien\44_NguyenThiAnhThu_B13\39_NguyenThiAnhThu_KT2\full_backup_qlchk.bak'
WITH RECOVERY;
--c. Kế hoạch lập lịch sao lưu gồm: loại sao lưu (FULL/DIFFERENTIAL/LOG), tần suất sử dụng và mục đích
--Full back up: 4-5 a.m thứ hai và thứ năm
--Thứ 2->chủ nhật (11 a.m và 5 p.m): differential backup
--Thứ 2->chủ nhật(1 p.m và 7 p.m) : log backup

--3/ (1,5)
--Tạo tài khoản và gán quyền cho các nhóm người dùng
--a. Nhân viên cảng hàng không: Thêm, xóa, cập nhật chuyến bay, vé, hành khách
sp_addrole nv_hangkhong;

grant select, insert, delete, update 
on CHUYENBAY
to nv_hangkhong

grant select, insert, delete, update 
on VE
to nv_hangkhong

grant select, insert, delete, update 
on HANHKHACH
to nv_hangkhong
--b. Hành khách: Chỉ được mua và xem vé của mình
sp_addrole hanhkhach;

grant select
on VE
to hanhkhach

----4/ (1,5)
--Tạo tài khoản người dùng theo nhóm quyền người dùng
--a. Nhân viên cảng hàng không: Thơm, Hùng
sp_addlogin 'Thom','123';
sp_adduser 'Thom', 'Thom';
sp_addrolemember 'nv_hangkhong', 'Thom';
sp_addlogin 'Hung','123';
sp_adduser 'Hung', 'Hung';
sp_addrolemember 'nv_hangkhong', 'Hung';
--b. Hành khách: Thành, Bính
sp_addlogin 'Thanh'.'123';
sp_adduser 'Thanh', 'Thanh';
sp_addrolemember 'hanhkhach', 'Thanh';
sp_addlogin 'Binh','123';
sp_adduser 'Binh', 'Binh';
sp_addrolemember 'hanhkhach', 'Hung';

--5/ (2,0)
--a.Nhân viên cảng hàng không: Thêm chuyến bay mới; Huỷ chuyến bay;
--  Thống kê số lượng vé đã bán theo chuyến bay; Xuất danh sách hành khách theo chuyến bay

---Thêm chuyến bay
--create procedure pro_ThemChuyenBay
--	@MACB nvarchar(50),
--	@MASB_DI nvarchar(50),
--	@MASB_DEN nvarchar(50),
--	@NGAYGIO nvarchar(50),
--	@TONGCHO nvarchar(50)
--as
--begin
--	insert into CHUYENBAY (MACB, MASB_DI, MASB_DEN, NGAYGIO, TONGCHO)
--	values (@MACB, @MASB_DI, @MASB_DEN, @NGAYGIO, @TONGCHO);
--end;
--EXEC pro_ThemChuyenBay
begin transaction;
	INSERT INTO  CHUYENBAY(MACB, MASB_DI, MASB_DEN, NGAYGIO, TONGCHO)
	VALUES ('VJ701', 'SGN', 'CXR', '2025-12-28 09:00', 200);
commit transaction;
---Hủy chuyến bay

---Thống kê số lượng vé đã bán theo chuyến bay

---Xuất danh sách hành khách theo chuyến bay
begin transaction;
	select hk.MAHK, hk.HOTEN,hk.CMND, cb.MACB
	from HANHKHACH hk, CHUYENBAY cb, VE 
	where hk.MAHK=VE.MAHK AND cb.MACB=VE.MACB
commit transaction;
--b. Hành khách: Đăng ký mua vé; Huỷ vé chưa khởi hành; Xem chi tiết vé của mình
---Đăng ký mua vé
---Xem chi tiết vé
begin transaction;
	select MAVE,MAHK,MACB,LOAI,GIA
	from VE 
	where MAVE='V0001'
commit transaction;
